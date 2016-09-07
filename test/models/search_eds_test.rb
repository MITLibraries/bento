require 'test_helper'

class SearchEdsTest < ActiveSupport::TestCase
  test 'can search articles' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal(39_479, query['apinoaleph']['total'])
    end
  end

  test 'can search books' do
    VCR.use_cassette('popcorn non articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apibarton')
      assert_equal(79, query['apibarton']['total'])
    end
  end

  test 'invalid credentials' do
    VCR.use_cassette('invalid credentials') do
      query = SearchEds.new.search('popcorn', 'apibarton')
      assert_equal('invalid credentials', query)
    end
  end

  test 'normalized articles have expected title' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal(
        'Popcorn! : 100 sweet and savory recipes.',
        query['apinoaleph']['results'].first.title.split[0...9].join(' ')
      )
    end
  end

  test 'normalized articles have expected year' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal('2013', query['apinoaleph']['results'].first.year)
    end
  end

  test 'normalized articles have expected url' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal(
        'http://search.ebscohost.com/login.aspx?direct=true&site=eds-live&db=edshlc&AN=edshlc.013683931-2',
        query['apinoaleph']['results'].first.url
      )
    end
  end

  test 'normalized articles have expected type' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal('Book', query['apinoaleph']['results'].first.type)
    end
  end

  test 'normalized articles have expected authors' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal(
        'Beckerman, Carol',
        query['apinoaleph']['results'].first.authors.first
      )
      assert_equal(1, query['apinoaleph']['results'].first.authors.count)
    end
  end

  test 'searches with no results do not error' do
    VCR.use_cassette('no results',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcornandorangejuice', 'apinoaleph')
      assert_equal(0, query['apinoaleph']['total'])
    end
  end

  test 'Handles NoMethodError: undefined method [] for nil:NilClass' do
    # https://rollbar.com/mit-libraries/bento/items/4/
    # The issue was the commas being treated delimiters
    VCR.use_cassette('rollbar4') do
      searchterm = 'R. F. Harrington, Field computation by moment methods. Macmillan, 1968'
      query = SearchEds.new.search(searchterm, 'apinoaleph')
      assert_equal(77612346, query['apinoaleph']['total'])
    end
  end

  test 'Handles NoMethodError: undefined method [] for nil:NilClass again' do
    # https://rollbar.com/mit-libraries/bento/items/4/
    # The issue was the commas being treated delimiters
    VCR.use_cassette('rollbar4a') do
      searchterm = 'R. F. Harrington, Field computation by moment methods. Macmillan, 1968'
      query = SearchEds.new.search(searchterm, 'apibarton')
      assert_equal(1268662, query['apibarton']['total'])
    end
  end

  test 'cleaner rf harrington' do
    VCR.use_cassette('rollbar4b') do
      searchterm = 'R. F. Harrington, Field computation by moment methods. Macmillan, 1968'
      expected = 'R.+F.+Harrington+Field+computation+by+moment+methods.+Macmillan+1968'
      assert_equal(expected, SearchEds.new.send(:clean_term, searchterm))
    end
  end
end
