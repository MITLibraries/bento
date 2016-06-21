require 'test_helper'

class SearchEdsTest < ActiveSupport::TestCase
  test 'valid search with valid credentials returns results' do
    VCR.use_cassette('valid search and credentials') do
      query = SearchEds.new.search('popcorn')
      assert_equal(
        2746, query['articles']['SearchResult']['Statistics']['TotalHits']
      )
    end
  end

  test 'invalid credentials' do
    VCR.use_cassette('invalid credentials') do
      query = SearchEds.new.search('popcorn')
      assert_equal('invalid credentials', query)
    end
  end
end
