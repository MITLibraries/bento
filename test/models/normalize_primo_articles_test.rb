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

  def book_chapter
    VCR.use_cassette('primo chapter',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('"spider monkey optimization algorithm"',
                                         ENV['PRIMO_ARTICLE_SCOPE'])
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_ARTICLE_SCOPE'], 
                                   '"spider monkey optimization algorithm"')
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

  def missing_fields_chapter
    # Note that this cassette has been manually eduited to remove the 
    # following fields from the first result: btitle, pages, date.
    VCR.use_cassette('missing fields primo chapter',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('"spider monkey optimization algorithm"',
                                         ENV['PRIMO_ARTICLE_SCOPE'])
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_ARTICLE_SCOPE'], 
                                   '"spider monkey optimization algorithm"')
    end
  end

  test 'constructs journal and chapter titles' do
    article_result = popcorn_articles['results'].first
    assert_equal 'Physics world', article_result.in

    chapter_result = book_chapter['results'].first
    assert_equal 'Evolutionary and Swarm Intelligence Algorithms', 
                 chapter_result.in
  end

  test 'handles results without titles' do
    article_result = missing_fields_articles['results'].first
    assert_nothing_raised { article_result.in }
    assert_nil article_result.in

    chapter_result = missing_fields_chapter['results'].first
    assert_nothing_raised { chapter_result.in }
    assert_nil chapter_result.in
  end

  test 'constructs citation info as expected' do
    article_result = popcorn_articles['results'].first
    assert_equal 'volume 29 issue 11', article_result.citation

    chapter_result = book_chapter['results'].first
    assert_equal "2018-06-07, pp. 43-59", chapter_result.citation
  end

  test 'handles results without citation info' do
    article_result = missing_fields_articles['results'].first
    assert_nothing_raised { article_result.citation }
    assert_nil article_result.citation

    chapter_result = missing_fields_chapter['results'].first
    assert_nothing_raised { chapter_result.citation }
    assert_nil chapter_result.citation
  end

  test 'handles results with partial citation info' do
    result = missing_fields_articles['results'].second
    assert_nothing_raised { result.citation }
    assert_equal 'volume 2012', result.citation
  end
end
