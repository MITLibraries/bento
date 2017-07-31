require 'test_helper'

class AlephHintTest < ActiveSupport::TestCase
  test 'loads and parses xml' do
    VCR.use_cassette('aleph hint', allow_playback_repeats: true) do
      xml = AlephHint.new
      assert(xml.marcxml.xml?)
    end
  end

  test 'load hints' do
    VCR.use_cassette('aleph hint', allow_playback_repeats: true) do
      assert_equal(4, Hint.count)
      AlephHint.new.process_records
      assert_equal(15, Hint.count)
      assert_equal('http://libraries.mit.edu/get/ericfull',
                   Hint.match('esubscribe').url)
      assert_equal('http://libraries.mit.edu/get/encislam',
                   Hint.match('Encyclopedia of Islam').url)
    end
  end

  test 'reload hints removes existing source hints but leaves other sources' do
    VCR.use_cassette('aleph hint', allow_playback_repeats: true) do
      Hint.upsert(title: 't', url: 'url', fingerprint: 'fp', source: 'aleph')
      assert_equal(1, Hint.where(source: 'aleph').count)
      assert_equal(4, Hint.where(source: 'manual').count)
      assert_equal('url', Hint.match('fp').url)
      AlephHint.new.reload
      assert_equal(11, Hint.where(source: 'aleph').count)
      assert_equal(4, Hint.where(source: 'manual').count)
      assert_nil(Hint.match('fp'))
    end
  end

  test 'reload hints rollsback on errors' do
    VCR.use_cassette('aleph hint loader error', allow_playback_repeats: true) do
      assert_equal(4, Hint.count)
      assert_raise ActiveRecord::RecordInvalid do
        AlephHint.new.reload
      end
      assert_equal(4, Hint.count)
    end
  end

  test 'get url is selected when there are multiple' do
    VCR.use_cassette('aleph hint', allow_playback_repeats: true) do
      AlephHint.new.process_records
      assert_equal('http://libraries.mit.edu/get/spie',
                   Hint.match('Acquisition, Tracking, and Pointing').url)
    end
  end

  test 'loader throws exception when encountering a record without a get url' do
    VCR.use_cassette('aleph hint loader error', allow_playback_repeats: true) do
      assert_raise ActiveRecord::RecordInvalid do
        AlephHint.new.process_records
      end
    end
  end
end
