require 'csv'
require 'test_helper'

class CustomHintTest < ActiveSupport::TestCase

  setup do
    @url = 'https://example.com/whatever.csv'
  end

  test 'fails without URL argument' do
    assert_raise ArgumentError do
      CustomHint.new
    end
  end

  test 'fails if CSV file not found at URL' do
    VCR.use_cassette('custom hint not csv', allow_playback_repeats: true) do
      hint = CustomHint.new('https://www.dropbox.com/s/hzeorpw7fa1xdda/this_is_a_cc0_kitten_pic_not_a_csv.jpeg?dl=1')
    end
  end

  test 'fails if CSV file lacks expected headers' do
    VCR.use_cassette('custom hint bad csv', allow_playback_repeats: true) do
      assert_raise RuntimeError do
        hint = CustomHint.new('https://www.dropbox.com/s/gg8t7sm8ne9wjjx/bad_csv.csv?dl=1')
        hint.process_records
      end
    end
  end

  test 'load hints' do
    VCR.use_cassette('custom hint', allow_playback_repeats: true) do
      assert_equal(6, Hint.count)
      CustomHint.new(@url).process_records
      assert_equal(127, Hint.count)
      assert_equal('http://libraries.mit.edu/get/ieee',
                   Hint.match('ieee xplore').url)
    end
  end

  test 'reload hints removes existing source hints' do
    VCR.use_cassette('custom hint', allow_playback_repeats: true) do
      Hint.upsert(title: 'snoxboops',
                  url: 'http://libraries.mit.edu/get/snoxboops',
                  fingerprint: 'snoxboops',
                  source: 'custom')
      assert_equal(5, Hint.where(source: 'custom').count)
      assert_equal('http://libraries.mit.edu/get/snoxboops',
                   Hint.match('snoxboops').url)

      CustomHint.new(@url).reload
      assert_equal(122, Hint.where(source: 'custom').count)
      assert_nil(Hint.match('snoxboops'))
    end
  end

  test 'reload hints leaves hints from other sources' do
    VCR.use_cassette('custom hint', allow_playback_repeats: true) do
      assert_equal(4, Hint.where(source: 'custom').count)
      assert_equal(2, Hint.where(source: 'aleph').count)

      CustomHint.new(@url).reload
      assert_equal(122, Hint.where(source: 'custom').count)
      assert_equal(2, Hint.where(source: 'aleph').count)
    end
  end

  test 'adds fingerprint if not present' do
    VCR.use_cassette('custom hint blank fingerprints', allow_playback_repeats: true) do
      url = 'https://www.dropbox.com/s/3dgxge8b14ht0c3/custom%20hint%20for%20test%20suite.csv?dl=1'
      CustomHint.new(url).process_records
      assert_equal('https://libraries.mit.edu/get/chinajournals',
                   Hint.match('cnki').url)
    end
  end

  test 'skips rows with neither fingerprint nor search' do
    VCR.use_cassette('custom hint blank fingerprints', allow_playback_repeats: true) do
      url = 'https://www.dropbox.com/s/3dgxge8b14ht0c3/custom%20hint%20for%20test%20suite.csv?dl=1'
      assert_equal(6, Hint.count)
      CustomHint.new(url).process_records
      assert_nil(Hint.find_by(title: 'No search here'))
      # Make sure it did create all the other hints, though, and not just skip
      # out on the ones after the skipped row.
      assert_equal(123, Hint.count)
    end
  end
end
