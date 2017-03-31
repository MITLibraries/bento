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
    VCR.use_cassette('popcorn books',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_equal('Popcorn handbook', query['results'][3].title)
    end
  end

  test 'can handle missing title titlefull and no item title' do
    VCR.use_cassette('popcorn books',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_equal('unknown title', query['results'][4].title)
    end
  end

  test 'can generate a local pagination link' do
    ENV['LOCAL_RESULTS'] = 'true'
    VCR.use_cassette('popcorn books',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_equal(
        '/search?q=popcorn&target=books',
        query['local_view_more']
      )
    end
  end

  test 'can generate an EDS UI paginaltion link' do
    VCR.use_cassette('popcorn books',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apiwhatnot', '')
      query = NormalizeEds.new.to_result(raw_query, 'books', 'popcorn')
      assert_equal(
        'http://libproxy.mit.edu/login?url=https%3A%2F%2Fsearch.ebscohost.com%2Flogin.aspx%3Fdirect%3Dtrue%26AuthType%3Dcookie%2Csso%2Cip%2Cuid%26type%3D0%26group%3Dedstest%26site%3Dedswhatnot%26profile%3Dedswhatnot%26bquery%3Dpopcorn&facet=Books,eBooks,Audiobooks,Dissertations,MusicScores,Audio,Videos',
        query['eds_ui_view_more']
      )
    end
  end
end
