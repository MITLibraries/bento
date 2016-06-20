require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] =
      OmniAuth.config.mock_auth[:mit_oauth2]
    OmniAuth.config.test_mode = true
  end

  def teardown
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:mit_oauth2] = nil
  end

  def silence_omniauth
    previous_logger = OmniAuth.config.logger
    OmniAuth.config.logger = Logger.new('/dev/null')
    yield
  ensure
    OmniAuth.config.logger = previous_logger
  end

  test 'accessing callback without credentials redirects to signin' do
    OmniAuth.config.mock_auth[:mit_oauth2] = :invalid_credentials
    silence_omniauth { get_via_redirect '/users/auth/mit_oauth2/callback' }
    assert_response :success
    assert_select '#sign_in', 'Sign in'
  end

  test 'accessing callback with for new user' do
    OmniAuth.config.mock_auth[:mit_oauth2] =
      OmniAuth::AuthHash.new(provider: 'mit_oauth2',
                             uid: '123545',
                             info: { email: 'bob@asdf.com' })
    usercount = User.count
    get_via_redirect '/users/auth/mit_oauth2/callback'
    assert_response :success
    assert_equal(usercount + 1, User.count)
  end
end
