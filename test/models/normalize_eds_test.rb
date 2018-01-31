require 'test_helper'

class NormalizeEdsTest < ActiveSupport::TestCase
  def setup
    ENV['LOCAL_RESULTS'] = nil
  end

  def after
    ENV['LOCAL_RESULTS'] = nil
  end

  test 'searches with no results do not error' do
    VCR.use_cassette('no results',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcornandorangejuice',
                                       'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'articles',
                                         'popcornandorangejuice')
      assert_equal(0, query['total'])
    end
  end

  test 'NoMethodError: private method select called for nil:NilClass' do
    # https://rollbar.com/mit-libraries/bento/items/180/
    VCR.use_cassette('popcorn books rollbar 180') do
      searchterm = 'popcorn'
      raw_query = SearchEds.new.search(searchterm, 'apiwhatnot',
                                       ENV['EDS_BOOK_FACETS'])
      query = NormalizeEds.new.to_result(raw_query, 'books', searchterm)
      assert_equal(212_131, query['total'])
    end
  end

  test 'Handles NoMethodError: undefined method [] for nil:NilClass' do
    # https://rollbar.com/mit-libraries/bento/items/4/
    # The issue was the commas being treated delimiters
    VCR.use_cassette('rollbar4') do
      searchterm = 'R. F. Harrington, Field computation by moment methods. '\
                   'Macmillan, 1968'
      raw_query = SearchEds.new.search(searchterm, 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'articles', searchterm)
      assert_equal(77_612_346, query['total'])
    end
  end

  test 'Handles NoMethodError: undefined method [] for nil:NilClass again' do
    # https://rollbar.com/mit-libraries/bento/items/4/
    # The issue was the commas being treated delimiters
    VCR.use_cassette('rollbar4a') do
      searchterm = 'R. F. Harrington, Field computation by moment methods. '\
                   'Macmillan, 1968'
      raw_query = SearchEds.new.search(searchterm, 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', searchterm)
      assert_equal(1_268_662, query['total'])
    end
  end

  test 'cleaner rf harrington' do
    VCR.use_cassette('rollbar4b') do
      searchterm = 'R. F. Harrington, Field computation by moment methods. '\
                   'Macmillan, 1968'
      assert_equal(
        'R.+F.+Harrington+Field+computation+by+moment+methods.+Macmillan+1968',
        SearchEds.new.send(:clean_term, searchterm)
      )
    end
  end

  test 'can handle missing years' do
    VCR.use_cassette('rollbar8') do
      searchterm = 'web of science'
      raw_query = SearchEds.new.search(searchterm, 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'articles', searchterm)
      assert_equal(37_667_909, query['total'])
      assert_nil(query['results'][0].year)
    end
  end

  test 'can handle missing title titlefull with item title' do
    VCR.use_cassette('popcorn books', allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_equal('Popcorn handbook', query['results'][3].title)
    end
  end

  test 'can handle missing title titlefull and no item title' do
    VCR.use_cassette('popcorn books', allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_equal('unknown title', query['results'][4].title)
    end
  end

  test 'uniform_title' do
    VCR.use_cassette('popcorn books', allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_equal(
        'Decoding representations of motherhood in American popular cinema'\
        ', 1979-1989.',
        query['results'][1].uniform_title
      )
    end
  end

  test 'can handle missing uniform_title' do
    VCR.use_cassette('popcorn books', allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_nil(query['results'][0].uniform_title)
    end
  end

  test 'does not use searchlink code titles for uniform_title' do
    VCR.use_cassette('ultimate hitchhiker', allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('ultimate hitchhiker', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(
        raw_query, 'books', 'ultimate hitchhiker'
      )
      assert_nil(query['results'][0].uniform_title)
    end
  end

  test 'can generate a local pagination link' do
    ENV['LOCAL_RESULTS'] = 'true'
    VCR.use_cassette('popcorn books', allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_equal(
        '/search?q=popcorn&target=books',
        query['local_view_more']
      )
    end
  end

  test 'can generate an EDS UI paginaltion link' do
    VCR.use_cassette('popcorn books', allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_equal(
        'http://libproxy.mit.edu/login?url=https%3A%2F%2Fsearch.ebscohost.com%2Flogin.aspx%3Fdirect%3Dtrue%26AuthType%3Dcookie%2Csso%2Cip%2Cuid%26type%3D0%26group%3Dedstest%26site%3Dedswhatnot%26profile%3Dedswhatnot%26bquery%3Dpopcorn&facet=Books,eBooks,Audiobooks,Dissertations,MusicScores,Audio,Videos',
        query['eds_ui_view_more']
      )
    end
  end

  test 'handle missing no dates and no IsPartOfRelationships' do
    VCR.use_cassette('turn of the screw', allow_playback_repeats: true) do
      raw_query = SearchEds.new.search(
        'turn of the screw', 'apiwhatnot', ENV['EDS_BOOK_FACETS'], 4, 1
      )
      query = NormalizeEds.new.to_result(
        raw_query, 'books', 'turn of the screw'
      )
      assert_nil(query['results'].first.year)
    end
  end

  test 'handle missing bibentity bits' do
    VCR.use_cassette('historico', allow_playback_repeats: true) do
      raw_query = SearchEds.new.search(
        'histórico da helmintosporiose', 'apiwhatnot',
        ENV['EDS_BOOK_FACETS'], 1, 5
      )
      query = NormalizeEds.new.to_result(
        raw_query, 'books', 'histórico da helmintosporiose'
      )
      assert(query['results'][0].valid?)
    end
  end

  test 'handle missing bibentity relationships' do
    VCR.use_cassette('National Cyclopaedia of American Biography',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search(
        'National Cyclopaedia of American Biography', 'apiwhatnot',
        ENV['EDS_ARTICLE_FACETS'], 1, 5
      )
      query = NormalizeEds.new.to_result(
        raw_query, 'articles', 'National Cyclopaedia of American Biography'
      )
      assert(query['results'][0].valid?)
    end
  end
end
