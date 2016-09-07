require 'test_helper'

class SearchTest < ActionDispatch::IntegrationTest
  test 'blank search term redirects to search' do
    get '/search/bento?q=%20'
    follow_redirect!
    assert_response :success
    assert_select('.alert') do |value|
      assert(value.text.include?('A search term is required.'))
    end
  end
end
