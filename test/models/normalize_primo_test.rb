require 'test_helper'

class NormalizePrimoTest < ActiveSupport::TestCase
  def popcorn
    VCR.use_cassette('popcorn primo',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('popcorn', 
                                         ENV['PRIMO_BOOK_SCOPE'])
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'], 
                                   'popcorn')
    end
  end

  def missing_fields
    # Note that this cassette has been manually edited to remove the 
    # following fields from the result: creationdate, title, author, 
    # contributor
    VCR.use_cassette('missing fields primo', 
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('Chʻomsŭkʻi, kkŭt ŏmnŭn tojŏn', 
                                         ENV['PRIMO_BOOK_SCOPE'])
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'], 
                                   'Chʻomsŭkʻi, kkŭt ŏmnŭn tojŏn')
    end
  end

  test 'searches with no results do not error' do
    VCR.use_cassette('no results primo',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('popcornandorangejuice',
                                         ENV['PRIMO_BOOK_SCOPE'])
      query = NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_BOOK_SCOPE'],
                                           'popcornandorangejuice')
      assert_equal(0, query['total'])
    end
  end

  test 'can handle missing year' do
    result = missing_fields['results'].first
    assert_nothing_raised { result.year }
    assert_nil result.year
  end

  test 'can handle missing title' do
    result = missing_fields['results'].first
    assert_nothing_raised { result.title }
    assert_equal 'unknown title', result.title
  end

  test 'can handle missing author' do
    result = missing_fields['results'].first
    assert_nothing_raised { result.authors }
    assert_nil result.authors
  end

  test 'can handle missing link' do
    result = missing_fields['results'].first
    assert_nothing_raised { result.url }
    assert_nil result.url
  end

  test 'can handle missing type' do
    result = missing_fields['results'].first
    assert_nothing_raised { result.type }
    assert_nil result.type
  end

  test 'authors are normalized and linked' do
    result = popcorn['results'].first
    assert_not_equal "Rudolph, J.$$QRudolph, J.", result.authors.first.first
    assert_equal ["Rudolph, J.",
                  "https://mit.primo.exlibrisgroup.com/discovery/search?query=creator,exact,Rudolph, J.&vid=FAKE_PRIMO_VID"],
                  result.authors.first
  end

  test 'types are normalized' do
    result = popcorn['results'].first
    assert_not_equal 'BKSE', result.type
    assert_equal 'eBook', result.type
  end

  test 'can handle bad results' do
    assert_raises NormalizePrimo::InvalidResults do
      NormalizePrimo.new.to_result('', ENV['PRIMO_BOOK_SCOPE'], 'popcorn')
    end
  end
end
