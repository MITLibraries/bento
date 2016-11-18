require 'test_helper'

class NormalizeEdsTest < ActiveSupport::TestCase
  test 'searches with no results do not error' do
    VCR.use_cassette('no results',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcornandorangejuice', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query, 'articles')
      assert_equal(0, query['total'])
    end
  end

  test 'Handles NoMethodError: undefined method [] for nil:NilClass' do
    # https://rollbar.com/mit-libraries/bento/items/4/
    # The issue was the commas being treated delimiters
    VCR.use_cassette('rollbar4') do
      searchterm = 'R. F. Harrington, Field computation by moment methods. '\
                   'Macmillan, 1968'
      raw_query = SearchEds.new.search(searchterm, 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query, 'articles')
      assert_equal(77_612_346, query['total'])
    end
  end

  test 'Handles NoMethodError: undefined method [] for nil:NilClass again' do
    # https://rollbar.com/mit-libraries/bento/items/4/
    # The issue was the commas being treated delimiters
    VCR.use_cassette('rollbar4a') do
      searchterm = 'R. F. Harrington, Field computation by moment methods. '\
                   'Macmillan, 1968'
      raw_query = SearchEds.new.search(searchterm, 'apibarton')
      query = NormalizeEds.new.to_result(raw_query, 'books')
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
      raw_query = SearchEds.new.search(searchterm, 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query, 'articles')
      assert_equal(37_667_909, query['total'])
      assert_nil(query['results'][0].year)
    end
  end

  test 'can handle missing title' do
    VCR.use_cassette('popcorn books',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apibarton')
      query = NormalizeEds.new.to_result(raw_query, 'books')
      assert_equal('unknown title', query['results'][3].title)
    end
  end
end
