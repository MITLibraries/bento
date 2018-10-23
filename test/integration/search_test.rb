require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
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
      get '/toggle?feature=local_full_record' # enable feature
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

  test 'multiple item types can be displayed' do
    VCR.use_cassette('why only us',
                     allow_playback_repeats: true) do
      get '/search/search_boxed?q=why+only+us&target=books'
      assert_response :success
      assert_select 'span.result-type', { text: 'Type: Book; eBook' }
    end
  end
end
