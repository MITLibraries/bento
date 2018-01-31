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
    assert_text('Try our beta "Details and requests" view')

    click_on('Try our beta "Details and requests" view')
    refute_text('Try our beta "Details and requests" view')
    assert_text('Turn off beta "Details and requests" view')

    click_on('Turn off beta "Details and requests" view')
    assert_text('Try our beta "Details and requests" view')
    refute_text('Turn off beta "Details and requests" view')
  end
end
