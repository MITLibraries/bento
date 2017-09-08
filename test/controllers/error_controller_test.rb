require 'test_helper'

class ErrorControllerTest < ActionDispatch::IntegrationTest
  test 'i_am_a_teapot' do
    get '/418'
    # You can't use assert_response(418) because it will raise an invalid
    # argument error, because for some absurd reason Rails doesn't implement
    # RFC 2324.
    assert_equal(@response.status, 418)
    assert_includes(@response.body, 'teapot')
  end
end
