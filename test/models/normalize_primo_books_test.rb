require 'test_helper'

class NormalizePrimoBooksTest < ActiveSupport::TestCase
  def popcorn_books
    VCR.use_cassette('popcorn primo books',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('popcorn', 
                                         ENV['PRIMO_BOOK_SCOPE'])
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'], 
                                   'popcorn')
    end
  end

  def missing_fields_books
    # Note that this cassette has been manually edited to remove the 
    # following fields from the first result: publisher, subject, holding, 
    # bestlocation, isbn
    VCR.use_cassette('missing fields primo books', 
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('popcorn', 
                                         ENV['PRIMO_BOOK_SCOPE'])
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'], 
                                   'popcorn')
    end
  end

  def physical_book
    VCR.use_cassette('physical book primo', 
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('Chʻomsŭkʻi, kkŭt ŏmnŭn tojŏn', 
                                         ENV['PRIMO_BOOK_SCOPE'])
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'], 
                                   'Chʻomsŭkʻi, kkŭt ŏmnŭn tojŏn')
    end
  end

  test 'constructs thumbnail links' do
    result = popcorn_books['results'].first
    assert_equal 'https://syndetics.com/index.php?client=primo&isbn=9789401708135/sc.jpg',
                 result.thumbnail
  end

  test 'handles results without thumbnails' do
    result = missing_fields_books['results'].first
    assert_nothing_raised { result.thumbnail }
    assert_nil result.thumbnail
  end

  test 'constructs subjects with links' do
    result = popcorn_books['results'].first
    assert_equal ["Geography",
                  "https://mit.primo.exlibrisgroup.com/discovery/search?query=sub,exact,Geography&vid=FAKE_PRIMO_VID"],
                  result.subjects.first
  end

  test 'handles results without subjects' do
    result = missing_fields_books['results'].first
    assert_nothing_raised { result.subjects }
    assert_nil result.subjects
  end

  test 'constructs locations as expected' do
    result = physical_book['results'].first
    assert_equal [['Library Storage Annex Off Campus Collection', 
                  'P85.C47.B56166 1998']], result.location
  end

  test 'does not construct locations for eresources' do
    result = popcorn_books['results'].first
    assert_nil result.location
  end

  test 'handles results without locations' do
    result = missing_fields_books['results'].first
    assert_nothing_raised { result.location }
    assert_nil result.location
  end
end
