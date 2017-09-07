require 'test_helper'

class HintControllerTest < ActionDispatch::IntegrationTest
  test 'hint with no query' do
    get '/hint'
    assert_response :success
  end

  test 'hint with query and no match' do
    get '/hint?q=purple+stuff'
    assert_response :success
    assert_empty(@response.body)
  end

  test 'hint with query and match' do
    get '/hint?q=INDSTAT'
    assert_response :success
    assert_includes(@response.body, 'UNIDO Statistics Data Portal')
  end

  test 'ga tracking' do
    cached_ga_key = ENV['GOOGLE_ANALYTICS']
    ENV['GOOGLE_ANALYTICS'] = 'UA-FAKE-KEY'

    # the test
    VCR.use_cassette('ga hint tracking', allow_playback_repeats: true) do
      get '/hint?q=INDSTAT'
      assert_response :success
    end

    ENV['GOOGLE_ANALYTICS'] = cached_ga_key
  end
end
