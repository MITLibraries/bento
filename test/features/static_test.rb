require 'test_helper'

class StaticTest < Capybara::Rails::TestCase
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

  test 'sign in link' do
    visit root_path
    assert_link('Sign in')
    refute_link('Sign out')
  end

  test 'sign out link' do
    OmniAuth.config.mock_auth[:mit_oauth2] =
      OmniAuth::AuthHash.new(provider: 'mit_oauth2',
                             uid: '123545',
                             info: { email: 'bob@asdf.com' })

    visit '/users/auth/mit_oauth2/callback'
    visit root_path
    assert_link('Sign out')
    refute_link('Sign in')
  end
end
