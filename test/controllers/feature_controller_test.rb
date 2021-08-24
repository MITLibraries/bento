require 'test_helper'

class FeatureControllerTest < ActionController::TestCase
  test 'can enable a feature' do
    refute_equal(session[:primo_search], false)
    get :toggle, params: { feature: 'primo_search' }
    assert_equal(session[:primo_search], true)
  end

  test 'can disable a feature' do
    session[:primo_search] = true
    assert_equal(session[:primo_search], true)
    get :toggle, params: { feature: 'primo_search' }
    refute_equal(session[:primo_search], true)
  end

  test 'handles invalid features' do
    refute_equal(session[:supah_cool_feature], true)
    get :toggle, params: { feature: 'supah_cool_feature' }
    refute_equal(session[:supah_cool_feature], true)
  end
end
