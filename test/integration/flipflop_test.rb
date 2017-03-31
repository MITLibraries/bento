require 'test_helper'

class FlipflopTest < ActionDispatch::IntegrationTest
  test 'can access dashboard with secret key' do
    get '/flipflop', params: { flipflop_key: ENV['FLIPFLOP_KEY'] }
    assert_response :success
  end

  test 'cannot acess dashboard without secret key' do
    get '/flipflop'
    assert_response :forbidden
  end

  test 'cannot access dashboard with wrong secret key' do
    get '/flipflop', params: { flipflop_key: 'not_the_key' }
    assert_response :forbidden
  end
end
