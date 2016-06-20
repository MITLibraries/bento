require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test 'should get home' do
    get :home
    assert_response :success
  end

  test 'anonymous user shows sign in link' do
    get :home
    assert_select '#sign_in', 'Sign in'
  end

  test 'signed in user shows sign out link' do
    sign_in users(:one)
    get :home
    assert_select '#sign_in', 'Sign out'
  end
end
