require 'test_helper'

class NormalizeTimdexTest < ActiveSupport::TestCase
  def timdex_records
    VCR.use_cassette('popcorn timdex',
                     allow_playback_repeats: true) do
      raw_query = SearchTimdex.new.search('popcorn')
      NormalizeTimdex.new.to_result(raw_query, 'popcorn')
    end
  end

  def aspace_records
    VCR.use_cassette('aspace timdex',
                     allow_playback_repeats: true) do
      raw_query = SearchTimdex.new.search('archives')
      NormalizeTimdex.new.to_result(raw_query, 'archives')
    end
  end

  test 'normalized timdex records have expected title' do
    assert_equal(
      'Popcorn Venus /',
      timdex_records['results'][0].title
    )
  end

  test 'normalized timdex records have expected url' do
    assert_equal(
      'https://library.mit.edu/item/000346597',
      timdex_records['results'][0].url
    )
  end

  test 'normalized timdex records have expected record count' do
    assert_equal(
      115,
      timdex_records['total']
    )
  end

  test 'normalized aspace records have an identifier in the title' do
    assert_match(
      'AC.0129',
      aspace_records['results'][0].title
    )
  end

  test 'normalized aspace records have a physical description' do
    assert_match(
      'Cubic Feet',
      aspace_records['results'][0].physical_description
    )
  end
end
