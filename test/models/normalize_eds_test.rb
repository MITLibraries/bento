require 'test_helper'

class NormalizeEdsTest < ActiveSupport::TestCase
  test 'normalized articles have expected title' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query)
      assert_equal(
        'Popcorn! : 100 sweet and savory recipes.',
        query['results'].first.title.split[0...9].join(' ')
      )
    end
  end

  test 'normalized articles have expected year' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query)
      assert_equal('2013', query['results'].first.year)
    end
  end

  test 'normalized articles have expected url' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query)
      assert_equal(
        'http://search.ebscohost.com/login.aspx?direct=true&site=eds-live&db=edshlc&AN=edshlc.013683931-2',
        query['results'].first.url
      )
    end
  end

  test 'normalized articles have expected type' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query)
      assert_equal('Book', query['results'].first.type)
    end
  end

  test 'normalized articles have expected authors' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query)
      assert_equal(
        'Beckerman, Carol',
        query['results'].first.authors.first
      )
      assert_equal(1, query['results'].first.authors.count)
    end
  end

  test 'searches with no results do not error' do
    VCR.use_cassette('no results',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcornandorangejuice', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query)
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
      query = NormalizeEds.new.to_result(raw_query)
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
      query = NormalizeEds.new.to_result(raw_query)
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
      query = NormalizeEds.new.to_result(raw_query)
      assert_equal(37_667_909, query['total'])
      assert_nil(query['results'].first.year)
    end
  end
end
