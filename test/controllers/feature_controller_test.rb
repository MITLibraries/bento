require 'test_helper'

class FeatureControllerTest < ActionController::TestCase
  test 'can enable a feature' do
    refute_equal(session[:debug], true)
    get :toggle, params: { feature: 'debug' }
    assert_equal(session[:debug], true)
  end

  test 'can disable a feature' do
    session[:debug] = true
    assert_equal(session[:debug], true)
    get :toggle, params: { feature: 'debug' }
    refute_equal(session[:debug], true)
  end

  test 'handles invalid features' do
    refute_equal(session[:supah_cool_feature], true)
    get :toggle, params: { feature: 'supah_cool_feature' }
    refute_equal(session[:supah_cool_feature], true)
  end
end
