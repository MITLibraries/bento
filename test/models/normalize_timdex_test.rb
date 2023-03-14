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
end
