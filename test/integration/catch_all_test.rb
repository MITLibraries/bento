require 'test_helper'

class CatchAllTest < ActionDispatch::IntegrationTest
  test 'handle 404s' do
    get '/blargh'
    assert_response :not_found
  end
end
