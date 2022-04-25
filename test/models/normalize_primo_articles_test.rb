require 'test_helper'

class NormalizePrimoArticlesTest < ActiveSupport::TestCase
  def popcorn_articles
    VCR.use_cassette('popcorn primo articles',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('popcorn',
                                         ENV['PRIMO_ARTICLE_SCOPE'], 5)
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_ARTICLE_SCOPE'],
                                   'popcorn')
    end
  end

  def book_chapter
    VCR.use_cassette('primo chapter',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('"spider monkey optimization algorithm"',
                                         ENV['PRIMO_ARTICLE_SCOPE'], 5)
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_ARTICLE_SCOPE'],
                                   '"spider monkey optimization algorithm"')
    end
  end

  def missing_fields_articles
    # Note that this cassette has been manually edited to remove the
    # following fields from the first result: jtitle, volume, issue,
    # almaOpenurl.
    # In the second result, the issue field has been removed.
    # In the last result, the almaOpenurl field server has been changed
    # from na06 to na07.
    VCR.use_cassette('missing fields primo articles',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('popcorn',
                                         ENV['PRIMO_ARTICLE_SCOPE'], 5)
      NormalizePrimo.new.to_result(raw_query, ENV['PRIMO_ARTICLE_SCOPE'],
                                   'popcorn')
    end
  end

  def missing_fields_chapter
    # Note that this cassette has been manually eduited to remove the
    # following fields from the first result: btitle, pages.
    VCR.use_cassette('missing fields primo chapter',
                     allow_playback_repeats: true) do
      raw_query = SearchPrimo.new.search('"spider monkey optimization algorithm"',
                                         ENV['PRIMO_ARTICLE_SCOPE'], 5)
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
    assert_equal '2018-06-07, pp. 43-59', chapter_result.citation
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

  # NOTE: after regenerating the cassette for this test, you will need to
  # copy the openurl params from the 'almaOpenUrl' element of the first
  # result in the response, and the full 'almaOpenUrl' element from the
  # last result. This is because a timestamp is included in the openurl
  # call and will change with each API call.
  test 'constructs full-text links as expected' do
    regular_result = popcorn_articles['results'].first
    assert_equal 'https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/primo.exlibrisgroup.com-crossref&rft.atitle=Popcorn&rft.date=2016-11&rft.eissn=2058-7058&rft.epage=42&rft.genre=article&rft.issn=0953-8585&rft.issue=11&rft.jtitle=Physics+world&rft.pages=42-42&rft.spage=42&rft.volume=29&rft_dat=<crossref>10_1088_2058_7058_29_11_46</crossref>&rft_id=info:doi/10.1088/2058-7058/29/11/46&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&svc_dat=viewit&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&url_ver=Z39.88-2004&vid=FAKE_PRIMO_VID',
                 regular_result.openurl

    irregular_result = missing_fields_articles['results'].last
    assert_equal 'https://na07.alma.exlibrisgroup.com/view/uresolver/01MIT_INST/openurl?ctx_enc=info:ofi/enc:UTF-8&ctx_id=10_1&ctx_tim=2021-05-19 10:29:20&ctx_ver=Z39.88-2004&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&url_ver=Z39.88-2004&rfr_id=info:sid/primo.exlibrisgroup.com-gale_cross&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&rft.genre=article&rft.atitle=Determination+of+perfluorinated+alkyl+acids+in+corn%2C+popcorn+and+popcorn+bags+before+and+after+cooking+by+focused+ultrasound+solid%E2%80%93liquid+extraction%2C+liquid+chromatography+and+quadrupole-time+of+flight+mass+spectrometry&rft.jtitle=Journal+of+Chromatography+A&rft.au=Moreta%2C+Cristina&rft.date=2014-08-15&rft.volume=1355&rft.spage=211&rft.epage=218&rft.pages=211-218&rft.issn=0021-9673&rft.coden=JOCRAM&rft_id=info:doi/10.1016%2Fj.chroma.2014.06.018&rft.pub=Elsevier+B.V&rft.place=Amsterdam&rft_dat=<gale_cross>A375736650</gale_cross>&svc_dat=viewit&rft_galeid=A375736650',
                 irregular_result.openurl
  end

  test 'handles results without full-text links' do
    result = missing_fields_articles['results'].first
    assert_nothing_raised { result.openurl }
    assert_nil result.openurl
  end
end
