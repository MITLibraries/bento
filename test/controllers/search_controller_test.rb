require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test 'should get home' do
    get :index
    assert_response :success
  end

  test 'should get bento' do
    VCR.use_cassette('valid search and credentials',
                     allow_playback_repeats: true) do
      get :bento, q: 'popcorn'
      assert_response :success
    end
  end
end
