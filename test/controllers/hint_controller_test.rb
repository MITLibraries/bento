require 'test_helper'

class HintControllerTest < ActionDispatch::IntegrationTest
  test 'hint with no query' do
    get '/hint'
    assert_response :success
  end

  test 'hint with query and no match' do
    get '/hint?q=purple+stuff'
    assert_response :success
    assert_empty(@response.body)
  end

  test 'hint with query and match' do
    get '/hint?q=INDSTAT'
    assert_response :success
    assert_includes(@response.body, 'UNIDO Statistics Data Portal')
  end
end
