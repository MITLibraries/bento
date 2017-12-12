require 'test_helper'

class AlephControllerTest < ActionDispatch::IntegrationTest
  test 'item_status' do
    VCR.use_cassette('realtime aleph') do
      get '/item_status?id=MIT01001739356'
      assert_response :success
    end
  end

  test 'full_item_status' do
    VCR.use_cassette('realtime aleph') do
      get '/full_item_status?id=MIT01001739356'
      assert_response :success
    end
  end

  test 'cache_path' do
    VCR.use_cassette('realtime aleph') do
      get '/full_item_status?id=MIT01001739356'
      assert_equal(@controller.send(:cache_path),
                   'http://www.example.com/full_item_status?id=MIT01001739356&method=full_item_status')
      assert_response :success
    end
  end
end
