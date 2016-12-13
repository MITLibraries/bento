require 'test_helper'

class AlertsTest < ActionDispatch::IntegrationTest
  def setup
    ENV['GLOBAL_ALERT'] = nil
  end

  def after
    ENV['GLOBAL_ALERT'] = nil
  end

  test 'no alert set does not display an alert' do
    get '/'
    assert_response :success
    assert_select('.alert', false)
  end

  test 'alert set display an alert' do
    ENV['GLOBAL_ALERT'] = 'This is an alert!!!'
    get '/'
    assert_response :success
    assert_select('.alert', true)
    assert_select('.alert') do |value|
      assert(value.text.include?('This is an alert!!!'))
    end
  end
end
