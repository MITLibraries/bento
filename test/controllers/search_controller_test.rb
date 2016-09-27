require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test 'should get home' do
    get :index
    assert_response :success
  end

  test 'should get bento' do
    # note, this does not test actual searching since javascript is not enabled
    # for controller tests. See integration tests for more related tests.
    get :bento, params: { q: 'popcorn' }
    assert_response :success
  end

  test 'should handle missing q parameter' do
    get :bento
    assert_response :redirect
  end
end
