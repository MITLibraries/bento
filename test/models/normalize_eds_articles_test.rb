require 'test_helper'

class NormalizeEdsArticlesTest < ActiveSupport::TestCase
  def popcorn_articles
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot',
                                       ENV['EDS_ARTICLE_FACETS'])
      NormalizeEds.new.to_result(raw_query, 'articles', 'popcorn')
    end
  end

  test 'normalized articles have expected title' do
    assert_equal(
      'History of northern corn leaf blight disease in the',
      popcorn_articles['results'][0].title.split[0...9].join(' ')
    )
  end

  test 'normalized articles have expected year' do
    assert_equal('2016', popcorn_articles['results'][0].year)
  end

  test 'normalized articles have expected record link' do
    assert_equal(
      'http://search.ebscohost.com/login.aspx?direct=true&site=eds-live&db=a9h&AN=117972338',
      popcorn_articles['results'][0].url
    )
  end

  test 'normalized articles have expected type' do
    assert_equal('Academic Journal', popcorn_articles['results'][0].type)
  end

  test 'normalized articles have expected authors' do
    assert_equal(
      'Moreira Ribeiro, Rodrigo',
      popcorn_articles['results'][0].authors[0][0]
    )
    assert_equal(6, popcorn_articles['results'][0].authors.count)
  end

  test 'normalized articles have expected author links' do
    assert_equal(
      'AU+%22Moreira+Ribeiro%2C+Rodrigo%22',
      popcorn_articles['results'][0].authors[0][1]
    )
  end

  test 'normalized articles can handle no authors' do
    VCR.use_cassette('no article authors',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('orange', 'apinoaleph', '')
      query = NormalizeEds.new.to_result(raw_query, 'articles', 'orange')
      assert_nil(query['results'][0].authors)
    end
  end

  test 'normalized articles can handle no bibrecord bibentity' do
    VCR.use_cassette('no bibrecord bibentity articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('Al Rahmaniyah Mosque', 'apiwhatnot',
                                       ENV['EDS_ARTICLE_FACETS'])
      query = NormalizeEds.new.to_result(raw_query, 'articles',
                                         'Al Rahmaniyah Mosque')
      assert_equal(57, query['total'])
    end
  end

  test 'normalized articles have expected citation' do
    assert_equal('volume 38 issue 4', popcorn_articles['results'][0].citation)
    assert_equal('volume 69', popcorn_articles['results'][1].citation)
    assert_equal('volume 6', popcorn_articles['results'][2].citation)
  end

  test 'normalized articles have expected in' do
    assert_equal(
      'Acta Scientiarum: Agronomy',
      popcorn_articles['results'][0].in
    )
    assert_equal('Journal of Cereal Science',
                 popcorn_articles['results'][1].in)
    assert_equal('Procedia Food Science', popcorn_articles['results'][2].in)
  end

  test 'normalized articles do not have subjects' do
    assert_nil(popcorn_articles['results'][0].subjects)
  end

  test 'normalized articles do not have location' do
    assert_nil(popcorn_articles['results'][0].location)
  end

  test 'normalized articles do not have publisher' do
    assert_nil(popcorn_articles['results'][0].publisher)
  end

  test 'normalized articles do not have thumbnail' do
    assert_nil(popcorn_articles['results'][0].thumbnail)
  end
end
