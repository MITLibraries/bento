require 'test_helper'

class SessionControllerTest < ActionDispatch::IntegrationTest
  test 'default session includes ENV set boxes' do
    get '/'
    assert_equal(
      session[:boxes],
      'website,books,articles,worldcat'.split(',')
    )
  end

  test 'can remove box from session' do
    get '/session/toggle_boxes?box=worldcat'
    follow_redirect!
    assert_equal(
      session[:boxes],
      'website,books,articles'.split(',')
    )
  end

  test 'can add box to session' do
    get '/session/toggle_boxes?box=popcorn'
    follow_redirect!
    assert_equal(
      session[:boxes],
      'website,books,articles,worldcat,popcorn'.split(',')
    )
  end
end
