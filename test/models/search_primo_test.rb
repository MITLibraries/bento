require 'test_helper'

class SearchPrimoTest < ActiveSupport::TestCase
  test 'can call Primo API' do
    VCR.use_cassette('popcorn primo books', allow_playback_repeats: true) do
      query = SearchPrimo.new.search('popcorn', ENV['PRIMO_BOOK_SCOPE'])
      assert_equal Hash, query.class
    end
  end

  test 'Local-scoped search returns local results' do
    VCR.use_cassette('popcorn primo books', allow_playback_repeats: true) do
      query = SearchPrimo.new.search('popcorn', ENV['PRIMO_BOOK_SCOPE'])
      assert_operator query['info']['total'], :>, 0
      assert_operator query['info']['totalResultsLocal'], :>, 0
      assert_equal query['info']['totalResultsLocal'], query['info']['total']
      assert_operator query['docs'].length, :>, 0
    end
  end

  test 'CDI-scoped search returns CDI results' do
    VCR.use_cassette('popcorn primo articles', allow_playback_repeats: true) do
      query = SearchPrimo.new.search('popcorn', ENV['PRIMO_ARTICLE_SCOPE'])
      assert_operator query['info']['total'], :>, 0
      assert_operator query['info']['totalResultsPC'], :>, 0
      assert_equal query['info']['totalResultsPC'], query['info']['total']
      assert_operator query['docs'].length, :>, 0
    end
  end

  test 'handles error states as expected' do
    VCR.use_cassette('bad primo response', allow_playback_repeats: true) do
      assert_raises "Primo Error Detected: 500 Internal Server Error" do 
        SearchPrimo.new.search('popcorn', ENV['PRIMO_BOOK_SCOPE'])
      end
    end
  end
end
