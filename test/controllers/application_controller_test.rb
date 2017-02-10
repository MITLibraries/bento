require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  test 'can enable debug' do
    refute_equal(session[:debug], true)
    get :debug
    assert_equal(session[:debug], true)
  end

  test 'can disable debug' do
    session[:debug] = true
    assert_equal(session[:debug], true)
    get :debug
    refute_equal(session[:debug], true)
  end
end
