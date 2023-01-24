require 'test_helper'
require 'climate_control'

class SearchTimdexTest < ActiveSupport::TestCase
  def setup
    ENV['TIMDEX_TIMEOUT'] = nil
  end

  def after
    ENV['TIMDEX_TIMEOUT'] = nil
  end

  test 'can search timdex' do
    VCR.use_cassette('popcorn timdex',
                     allow_playback_repeats: true) do
      query = SearchTimdex.new.search('popcorn')
      assert_equal(Hash, query.class)
    end
  end

  test 'can search timdexv2' do
    ClimateControl.modify(TIMDEX_URL: 'https://timdex-api-prod-v2.herokuapp.com/graphql') do
      VCR.use_cassette('popcorn timdex v2',
                       allow_playback_repeats: true) do
        test_strategy = Flipflop::FeatureSet.current.test!
        test_strategy.switch!(:timdex_v2, true)
        results = SearchTimdex.new.search('chomsky')
        assert_equal Hash, results.class
        assert results['data']['search']['hits'] > 0
      end
    end
  end

  test 'timdex quoted terms do not error' do
    VCR.use_cassette('quoted timdex',
                     allow_playback_repeats: true) do
      query = SearchTimdex.new.search('"kevin lynch"')
      refute(query['status'] == 400)
    end
  end

  test 'can change timeout value' do
    assert_equal(6, SearchTimdex.new.send(:http_timeout))

    ENV['TIMDEX_TIMEOUT'] = '0.1'
    assert_equal(0.1, SearchTimdex.new.send(:http_timeout))

    ENV['TIMDEX_TIMEOUT'] = '3'
    assert_equal(3, SearchTimdex.new.send(:http_timeout))
  end
end
