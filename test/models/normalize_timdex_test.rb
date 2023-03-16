require 'test_helper'

class NormalizeTimdexTest < ActiveSupport::TestCase
  def aspace_records
    VCR.use_cassette('aspace timdex',
                     allow_playback_repeats: true) do
      raw_query = SearchTimdex.new.search('archives')
      NormalizeTimdex.new.to_result(raw_query, 'archives')
    end
  end

  test 'normalized aspace records have an identifier in the title' do
    assert_match(
      'MC.0552',
      aspace_records['results'][0].title
    )
  end

  test 'normalized aspace records have a physical description' do
    assert_match(
      'Cubic Feet',
      aspace_records['results'][0].physical_description
    )
  end

  test 'normalized aspace records have a creation date range' do
    assert_equal '1914-1998', aspace_records['results'][0].year
  end

  test 'normalized aspace records have an array of contributors' do
    assert aspace_records['results'][0].authors.is_a? Array
    assert_equal 'Earls, Paul, 1934-1998', aspace_records['results'][0].authors[0][0]
  end

  test 'normalized aspace records have a summary' do
    assert_match 'The Paul Earls archives contains a large number of music manuscript',
                 aspace_records['results'][0].blurb
  end

  # Some ASpace records have a publication date range rather than a creation date range. The following regression test
  # ensures that the NormalizeTimdex model does not error for such records.
  test 'records with no creation date do not error' do
    VCR.use_cassette('aspace publication date',
                     allow_playback_repeats: true) do
      raw_query = SearchTimdex.new.search('SOVEREIGN INTIMACY: PRIVATE MEDIA AND THE TRACES OF COLONIAL VIOLENCE')
      assert_not raw_query['data']['search']['records'].first['dates'].first['kind'] == 'creation'
      assert_nothing_raised do
        NormalizeTimdex.new.to_result(raw_query, 'SOVEREIGN INTIMACY: PRIVATE MEDIA AND THE TRACES OF COLONIAL VIOLENCE')
      end
    end
  end

  # This is another regression test. Now that we know that records with no creation date will not error, we also want
  # to ensure that records with a publication date will be normalized accordingly.
  test 'publication dates are normalized' do
    VCR.use_cassette('aspace publication date',
                     allow_playback_repeats: true) do
      raw_query = SearchTimdex.new.search('SOVEREIGN INTIMACY: PRIVATE MEDIA AND THE TRACES OF COLONIAL VIOLENCE')
      normalized = NormalizeTimdex.new.to_result(raw_query, 'SOVEREIGN INTIMACY: PRIVATE MEDIA AND THE TRACES OF COLONIAL VIOLENCE')

      assert_equal 'publication', raw_query['data']['search']['records'].first['dates'].first['kind']
      assert_equal '1940', raw_query['data']['search']['records'].first['dates'].first['range']['gte']
      assert_equal '1983', raw_query['data']['search']['records'].first['dates'].first['range']['lte']
      assert_equal '1940-1983', normalized['results'][0].year
    end
  end

  test 'normalizer selects the first of two relevant dates' do
    VCR.use_cassette('aspace multiple creation dates') do
      raw_query = SearchTimdex.new.search('Timurid Architecture Research Archive')
      assert raw_query['data']['search']['records'].first['dates'].count > 1
      assert_not_equal raw_query['data']['search']['records'].first['dates'].first,
                       raw_query['data']['search']['records'].first['dates'].second

      start_date = raw_query['data']['search']['records'].first['dates'].first['range']['gte']
      end_date = raw_query['data']['search']['records'].first['dates'].first['range']['lte']
      normalized = NormalizeTimdex.new.to_result(raw_query, 'Timurid Architecture Research Archive')
      assert_equal "#{start_date}-#{end_date}", normalized['results'][0].year
    end
  end
end
