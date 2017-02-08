require 'test_helper'

class AlephControllerTest < ActionDispatch::IntegrationTest
  test 'index' do
    VCR.use_cassette('realtime aleph') do
      get '/item_status?id=MIT01001739356'
      assert_response :success
    end
  end
end
