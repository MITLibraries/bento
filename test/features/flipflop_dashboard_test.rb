require 'test_helper'

feature 'FlipflopDashboard' do
  before do
    Capybara.current_session.driver.browser.clear_cookies
  end

  after do
    Capybara.current_session.driver.browser.clear_cookies
  end

  test 'can toggle a feature from the dashboard' do
    visit "/flipflop?flipflop_key=#{ENV['FLIPFLOP_KEY']}"

    within('tr[data-feature=debug] td[data-strategy=session]') do
      click_on 'on'
    end

    within('tr[data-feature=debug]') do
      assert_equal('on', first('td.status').text)
      assert_equal('on', first('td[data-strategy=session] button.active').text)
    end
  end
end
