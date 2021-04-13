require 'test_helper'

class SearchPrimoTest < ActiveSupport::TestCase
  test 'can call Primo API' do
    VCR.use_cassette('popcorn primo', allow_playback_repeats: true) do
      query = SearchPrimo.new.search('popcorn')
      assert_equal Hash, query.class
    end
  end

  test 'searching returns a list of results' do
    VCR.use_cassette('popcorn primo', allow_playback_repeats: true) do
      query = SearchPrimo.new.search('popcorn')
      assert_operator query['info']['total'], :>, 0
      assert_operator query['docs'].length, :>, 0
    end
  end

  test 'handles error states as expected' do
    VCR.use_cassette('bad primo response', allow_playback_repeats: true) do
      assert_raises "Primo Error Detected: 500 Internal Server Error" do 
        SearchPrimo.new.search('popcorn')
      end
    end
  end
end
