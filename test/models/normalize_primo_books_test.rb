require 'test_helper'

class NormalizePrimoBooksTest < ActiveSupport::TestCase
  def popcorn_books
    VCR.use_cassette('popcorn primo books',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('popcorn', 
                                         ENV['PRIMO_BOOK_SCOPE'], 5)
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
                                         ENV['PRIMO_BOOK_SCOPE'], 5)
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'], 
                                   'popcorn')
    end
  end

  def physical_book
    VCR.use_cassette('physical book primo', 
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('Chʻomsŭkʻi, kkŭt ŏmnŭn tojŏn', 
                                         ENV['PRIMO_BOOK_SCOPE'], 5)
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'], 
                                   'Chʻomsŭkʻi, kkŭt ŏmnŭn tojŏn')
    end
  end

  def unavailable_book
    VCR.use_cassette('unavailable book primo',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('they called us enemy',
                                         ENV['PRIMO_BOOK_SCOPE'], 5)
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'],
                                   'they called us enemy')
    end
  end

  def partially_available_book
    # Note that when this cassette was generated, the first result had 
    # one volume checked out.
    VCR.use_cassette('partially available book primo',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('works of michael de montaigne',
                                         ENV['PRIMO_BOOK_SCOPE'], 5)
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'],
                                   'works of michael de montaigne')
    end
  end

  def multiple_availability_book
    VCR.use_cassette('multi available book primo', 
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('chomsky lyons',
                                         ENV['PRIMO_BOOK_SCOPE'], 5)
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'],
                                   'chomsky lyons')
    end
  end

  def multi_location
    VCR.use_cassette('local journal primo',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('Journal of heat transfer',
                                          ENV['PRIMO_BOOK_SCOPE'], 5)
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'],
                                   'Journal of heat transfer')
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
                  "https://mit.primo.exlibrisgroup.com/discovery/browse?browseQuery=Geography&browseScope=subject.1&vid=FAKE_PRIMO_VID"],
                  result.subjects.first
  end

  test 'handles results without subjects' do
    result = missing_fields_books['results'].first
    assert_nothing_raised { result.subjects }
    assert_nil result.subjects
  end

  test 'removes hyphens from subject links' do
    result = physical_book['results'].first
    assert_equal ['Linguists -- United States',
                  'https://mit.primo.exlibrisgroup.com/discovery/browse?browseQuery=Linguists United States&browseScope=subject.1&vid=FAKE_PRIMO_VID'],
                 result.subjects.second
  end

  test 'constructs location as expected' do
    result = physical_book['results'].first
    assert_equal ['Library Storage Annex Off Campus Collection', 
                  'P85.C47.B56166 1998'], result.location
  end

  test 'ignores additional locations' do
    result = multi_location['results'].first
    assert_not_equal ['Barker Library Microforms', 'FICHE No Call #'], 
                     result.location
    assert_equal ['Library Storage Annex Journal Collection (LSA4)', 
                  'TA.J86.H437'], 
                 result.location
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

  test 'constructs full-text links as expected' do
    result = popcorn_books['results'].first
    assert_equal "https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&vid=FAKE_PRIMO_VID&rft.mms_id=990022823660206761&u.ignore_date_coverage=true",
                 result.openurl
  end

  test 'handles results without full-text links' do
    result = physical_book['results'].first
    assert_nothing_raised { result.url }
    assert_nil result.openurl
  end

  test 'extracts availability status as expected' do
    available_result = multi_location['results'].first
    maybe_available_result = partially_available_book['results'].first
    unavailable_result = unavailable_book['results'].first
    assert_equal 'available', available_result.availability
    assert_equal 'check_holdings', maybe_available_result.availability
    assert_equal 'unavailable', unavailable_result.availability
  end

  test 'assesses additional availability as expected' do
    single_availability = physical_book['results'].first
    possible_availability = partially_available_book['results'].first
    no_availability = unavailable_book['results'].first
    multi_availability = multiple_availability_book['results'].first
    assert_equal false, single_availability.other_availability
    assert_equal false, possible_availability.other_availability
    assert_equal false, no_availability.other_availability
    assert_equal true, multi_availability.other_availability
  end

  test 'handles results without availability status' do
    result = missing_fields_books['results'].first
    assert_nothing_raised { result.availability }
    assert_nothing_raised { result.other_availability }
    assert_nil result.availability
    assert_nil result.other_availability
  end
end
