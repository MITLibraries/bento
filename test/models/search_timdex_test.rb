require 'test_helper'

class SearchTimdexTest < ActiveSupport::TestCase
  test 'can search timdex' do
    VCR.use_cassette('popcorn timdex',
                     allow_playback_repeats: true) do
      query = SearchTimdex.new.search('popcorn')
      assert_equal(Hash, query.class)
    end
  end
end
