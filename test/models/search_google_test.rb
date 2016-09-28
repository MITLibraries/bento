require 'test_helper'
require 'google/apis/customsearch_v1'

class SearchGoogleTest < ActiveSupport::TestCase
  test 'valid google search with valid credentials returns results' do
    VCR.use_cassette('valid google search and credentials') do
      raw_query = SearchGoogle.new.search('endnote')
      assert_equal('customsearch#search', raw_query.kind)
    end
  end

  test 'invalid credentials' do
    VCR.use_cassette('invalid google credentials') do
      msg = assert_raises(Google::Apis::ClientError) do
        SearchGoogle.new.search('endnote')
      end
      assert_equal('keyInvalid: Bad Request', msg.message)
    end
  end
end
