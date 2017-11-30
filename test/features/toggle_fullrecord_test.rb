require 'test_helper'

feature 'ToggleFullrecord' do
  before do
    Capybara.current_session.driver.browser.clear_cookies
  end

  after do
    Capybara.current_session.driver.browser.clear_cookies
  end

  test 'can toggle full record from app' do
    visit '/'
    assert_text('Preview beta record display.')

    click_on('Preview beta record display.')
    refute_text('Preview beta record display.')
    assert_text('Disable beta record display.')

    click_on('Disable beta record display.')
    assert_text('Preview beta record display.')
    refute_text('Disable beta record display.')
  end
end
