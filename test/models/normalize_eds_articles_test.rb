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

  test 'normalized articles have expected url eds provided sfx link' do
    assert_equal(
      'https://sfx.mit.edu/sfx_local?rfr_id=info%3Asid%2FMIT.BENTO&rft.au=Moreira+Ribeiro%2C+Rodrigo%3Bdo+Amaral+J%C3%BAnior%2C+Ant%C3%B4nio+Teixeira%3BFerreira+Pena%2C+Guilherme%3BVivas%2C+Marcelo%3BNascimento+Kurosawa%2C+Railan%3BAzeredo+Gon%C3%A7alves%2C+Leandro+Sim%C3%B5es&rft.issue=4&rft.jtitle=Acta+Scientiarum%3A+Agronomy&rft.volume=38&rft.year=2016&rft_id=info%3Adoi%2F10.4025%2Factasciagron.v38i4.30573',
      popcorn_articles['results'][0].get_it_url
    )
  end

  test 'normalized articles have generated sfx link when not in eds' do
    assert_equal(
      'https://sfx.mit.edu/sfx_local?genre=article&isbn=&issn=07335210&title=Journal%20of%20Cereal%20Science&volume=69&issue=&date=20160501&atitle=Sensory%20and%20nutritional%20evaluation%20of%20popcorn%20kernels%20with%20yellow,%20white%20and%20red%20pericarps%20expanded%20in%20different%20ways&aulast=Paraginski,%20Ricardo%20Tadeu&spage=383&sid=EBSCO:ScienceDirect&pid=%3Cauthors%3EParaginski,%20Ricardo%20Tadeu%3C/authors%3E%3Cui%3ES0733521016300753%3C/ui%3E%3Cdate%3E20160501%3C/date%3E%3Cdb%3EScienceDirect%3C/db%3E&rfr_id=info:sid/MIT.BENTO',
      popcorn_articles['results'][1].get_it_url
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
      'http://libproxy.mit.edu/login?url=https%3A%2F%2Fsearch.ebscohost.com%2Flogin.aspx%3Fdirect%3Dtrue%26AuthType%3Dcookie%2Csso%2Cip%2Cuid%26type%3D0%26group%3Dedstest%26site%3Dedswhatnot%26profile%3Dedswhatnot%26bquery%3DAU+%22Moreira+Ribeiro%2C+Rodrigo%22',
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

  test 'normalized articles have expected availability' do
    skip('need to determine logic to how this will work without misleading')
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
