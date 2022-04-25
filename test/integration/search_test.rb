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

  test 'raise 404 on invalid target' do
    get '/search/search_boxed?q=popcorn&target=hackor'
    assert_response :not_found
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
end
