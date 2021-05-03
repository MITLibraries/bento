require 'test_helper'

class NormalizePrimoArticlesTest < ActiveSupport::TestCase
  def popcorn_articles
    VCR.use_cassette('popcorn primo articles',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('popcorn', 
                                         ENV['PRIMO_ARTICLE_SCOPE'])
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_ARTICLE_SCOPE'], 
                                   'popcorn')
    end
  end

  def missing_fields_articles
    # Note that this cassette has been manually edited to remove the 
    # following fields from the first result: jtitle, volume, issue.
    # And the following field from the second result: issue.
    VCR.use_cassette('missing fields primo articles', 
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('popcorn', 
                                         ENV['PRIMO_ARTICLE_SCOPE'])
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_ARTICLE_SCOPE'], 
                                   'popcorn')
    end
  end

  test 'constructs journal titles' do
    result = popcorn_articles['results'].first
    assert_equal 'Physics world', result.in
  end

  test 'handles results without journal titles' do
    result = missing_fields_articles['results'].first
    assert_nothing_raised { result.in }
    assert_nil result.in
  end

  test 'citation info is constructed as expected' do
    result = popcorn_articles['results'].first
    assert_equal 'volume 29 issue 11', result.citation
  end

  test 'handles results without citation info' do
    result = missing_fields_articles['results'].first
    assert_nothing_raised { result.citation }
    assert_nil result.citation
  end

  test 'handles results with partial citation info' do
    result = missing_fields_articles['results'].second
    assert_nothing_raised { result.citation }
    assert_equal 'volume 2012', result.citation
  end
end
