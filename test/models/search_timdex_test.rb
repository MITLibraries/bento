require 'test_helper'

class SearchTimdexTest < ActiveSupport::TestCase
  def setup
    ENV['TIMDEX_TIMEOUT'] = nil
  end

  def after
    ENV['TIMDEX_TIMEOUT'] = nil
  end

  test 'can search timdex' do
    VCR.use_cassette('aspace timdex',
                     allow_playback_repeats: true) do
      response = SearchTimdex.new.search('archives')
      assert_equal Hash, response.class
      assert response['data']['search']['hits'] > 0
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
