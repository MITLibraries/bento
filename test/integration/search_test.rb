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
    get '/search/search?q=%20'
    follow_redirect!
    assert_response :success
    assert_select('.alert') do |value|
      assert(value.text.include?('A search term is required.'))
    end
  end

  test 'missing search term sends error' do
    get '/search/search'
    follow_redirect!
    assert_response :success
    assert_select('.alert') do |value|
      assert(value.text.include?('A search term is required.'))
    end
  end

  test 'article results are populated' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      get '/search/search?q=popcorn&target=articles'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert(value.text.include?('100 sweet and savory'))
      end
    end
  end

  test 'book results are populated' do
    VCR.use_cassette('popcorn non articles',
                     allow_playback_repeats: true) do
      get '/search/search?q=popcorn&target=books'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert(value.text.include?('fifty years of rock'))
      end
    end
  end

  test 'google results are populated' do
    VCR.use_cassette('popcorn google',
                     allow_playback_repeats: true) do
      get '/search/search?q=popcorn&target=google'
      assert_response :success
      assert_select('a.bento-link') do |value|
        assert(value.text.include?('Family Weekend'))
      end
    end
  end

  test 'invalid target' do
    get '/search/search?q=popcorn&target=hackor'
    follow_redirect!
    assert_response :success
  end
end
