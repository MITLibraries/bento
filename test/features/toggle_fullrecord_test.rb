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
    assert_text('Try our new beta item detail view')

    click_on('Try our new beta item detail view')
    refute_text('Try our new beta item detail view')
    assert_text('Turn off beta item detail view')

    click_on('Turn off beta item detail view')
    assert_text('Try our new beta item detail view')
    refute_text('Turn off beta item detail view')
  end
end
