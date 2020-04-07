require 'test_helper'

class SearchTimdexTest < ActiveSupport::TestCase
  test 'can search timdex' do
    VCR.use_cassette('popcorn timdex',
                     allow_playback_repeats: true) do
      query = SearchTimdex.new.search('popcorn')
      assert_equal(Hash, query.class)
    end
  end

  test 'timdex quoted terms do not error' do
    VCR.use_cassette('quoted timdex',
      allow_playback_repeats: true) do
        query = SearchTimdex.new.search('"kevin lynch"')
        refute(query['status'] == 400)
      end
  end
end
