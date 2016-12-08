require 'test_helper'

class SearchEdsTest < ActiveSupport::TestCase
  test 'can search articles' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      assert_equal(Hash, query.class)
    end
  end

  test 'can search books' do
    VCR.use_cassette('popcorn non articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      assert_equal(Hash, query.class)
    end
  end

  test 'invalid credentials' do
    VCR.use_cassette('invalid credentials') do
      query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      assert_equal('invalid credentials', query)
    end
  end
end
