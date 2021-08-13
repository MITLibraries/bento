require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
  def setup
    @test_strategy = Flipflop::FeatureSet.current.test!
  end
  def teardown
    @test_strategy = Flipflop::FeatureSet.current.test!
  end

  test 'blank search term redirects to search' do
    get '/search/bento?q=%20'
    follow_redirect!
    assert_response :success
    assert_select('.alert') do |value|
      assert(value.text.include?('A search term is required.'))
    end
  end

  test 'blank search term sends error' do
    get '/search/search_boxed?q=%20'
    follow_redirect!
    assert_response :success
    assert_select('.alert') do |value|
      assert(value.text.include?('A search term is required.'))
    end
  end

  test 'missing search term sends error' do
    get '/search/search_boxed'
    follow_redirect!
    assert_response :success
    assert_select('.alert') do |value|
      assert(value.text.include?('A search term is required.'))
    end
  end

  test 'article results are populated' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=popcorn&target=articles'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert(value.text.include?('History of northern corn leaf'))
      end
    end
  end

  test 'book results are populated' do
    VCR.use_cassette('popcorn non articles',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=popcorn&target=books'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert(value.text.include?('fifty years of rock'))
      end
    end
  end

  test 'Primo local results are populated' do
    VCR.use_cassette('popcorn primo books',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=popcorn&target=FAKE_PRIMO_BOOK_SCOPE'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert value.text.include?('Atmospheric Measurements during POPCORN')
      end
    end
  end

  test 'Primo CDI results are populated' do
    VCR.use_cassette('popcorn primo articles',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=popcorn&target=FAKE_PRIMO_ARTICLE_SCOPE'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert value.text.include?('Baryonic popcorn')
      end
    end
  end

  test 'google results are populated' do
    VCR.use_cassette('popcorn google',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=popcorn&target=google'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert(value.text.include?('Family Weekend'))
      end
    end
  end

  test 'timdex results are populated' do
    VCR.use_cassette('popcorn timdex',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=popcorn&target=timdex'
      assert_response :success
    end
  end

  test 'invalid target' do
    get '/search/search_boxed?q=popcorn&target=hackor'
    follow_redirect!
    assert_response :success
  end

  test 'pagination' do
    VCR.use_cassette('popcorn books paginated',
                     allow_playback_repeats: true) do
      get '/search?q=popcorn&target=books'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert(value.text.include?('fifty years of rock'))
      end
      assert_select('span.page.current') do |value|
        assert_equal(1, value.text.to_i)
      end
      assert_select('span.next a') do |value|
        assert_equal(
          '/search?page=2&q=popcorn&target=books',
          value.first['href']
        )
      end
    end
  end

  test 'local full_record_link when enabled' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      @test_strategy.switch!(:local_full_record, true) # enable feature
      get '/search/search_boxed?q=popcorn&target=articles'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert(value.text.include?('History of northern corn leaf'))
        assert(value.xpath('./@href').text.exclude?('http://search.ebscohost.com/login.aspx'))
      end
    end
  end

  test 'remote full_record_link when local not enabled' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=popcorn&target=articles'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert(value.text.include?('History of northern corn leaf'))
        assert(value.xpath('./@href').text.include?('http://search.ebscohost.com/login.aspx'))
      end
    end
  end

  test 'dedup full_record_link when relevant' do
    VCR.use_cassette('beloved primo',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=beloved%20morrison&target=FAKE_PRIMO_BOOK_SCOPE'
      assert_response :success
      url = 'https://mit.primo.exlibrisgroup.com/discovery/search?facet=frbrgroupid%2Cinclude%2C9073697300638768684&query=any%2Ccontains%2Cbeloved+morrison&search_scope=FAKE_PRIMO_BOOK_SCOPE&sortby=date_d&tab=FAKE_PRIMO_TAB&vid=FAKE_PRIMO_VID'
      assert_select 'a.bento-link' do |value|
        assert(value.text.include?('Beloved'))
        assert(value.xpath('./@href').text.include?(url))
      end
    end
  end

  test 'multiple item types can be displayed' do
    VCR.use_cassette('why only us',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=why+only+us&target=books'
      assert_response :success
      assert_select 'span.result-type', { text: 'Type: Book; eBook' }
    end
  end
end
