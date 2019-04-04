require 'test_helper'

class SearchEdsTest < ActiveSupport::TestCase
  def setup
    ENV['EDS_TIMEOUT'] = nil
  end

  def after
    ENV['EDS_TIMEOUT'] = nil
  end

  test 'can search articles' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apiwhatnot',
                                   ENV['EDS_ARTICLE_FACETS'])
      assert_equal(Hash, query.class)
    end
  end

  test 'can search books' do
    VCR.use_cassette('popcorn non articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apiwhatnot',
                                   ENV['EDS_BOOK_FACETS'])
      assert_equal(Hash, query.class)
    end
  end

  test 'invalid credentials' do
    error = assert_raise RuntimeError do
      VCR.use_cassette('invalid credentials') do
        SearchEds.new.search('popcorn', 'apiwhatnot', '')
      end
    end
    assert_match(/unable to get credentials/, error.message)
  end

  test 'can change timeout value' do
    VCR.use_cassette('custom timeout') do
      assert_equal(6, SearchEds.new.send(:http_timeout))
    end

    ENV['EDS_TIMEOUT'] = '0.1'
    VCR.use_cassette('custom timeout') do
      assert_equal(0.1, SearchEds.new.send(:http_timeout))
    end

    ENV['EDS_TIMEOUT'] = '3'
    VCR.use_cassette('custom timeout') do
      assert_equal(3, SearchEds.new.send(:http_timeout))
    end
  end

  test 'general eds error handling' do
    error = assert_raise RuntimeError do
      VCR.use_cassette('eds general error', allow_playback_repeats: true) do
        SearchEds.new.search(
          'popcorn', 'apiwhatnot', ENV['EDS_ARTICLE_FACETS'], 1, 5
        )
      end
    end
    assert_match(/EDS Error Detected/, error.message)
  end
end
