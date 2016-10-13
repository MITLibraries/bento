require 'test_helper'

class SearchWorldcatTest < ActiveSupport::TestCase
  test 'valid worldcat search with valid credentials returns results' do
    VCR.use_cassette('valid worldcat search and credentials') do
      raw_query = SearchWorldcat.new.search('popcorn')
      assert_equal(HTTP::Response, raw_query.class)
    end
  end

  test 'invalid credentials' do
    VCR.use_cassette('invalid worldcat credentials') do
      response = SearchWorldcat.new.search('popcorn')
      assert_equal(response.status, 407)
    end
  end
end
