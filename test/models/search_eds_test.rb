require 'test_helper'

class SearchEdsTest < ActiveSupport::TestCase
  test 'can search articles' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal(39_812, query['apinoaleph']['total'])
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
        'Sowing time of popcorn during the summer harvest under',
        query['apinoaleph']['results'].first.title.split[0...9].join(' ')
      )
    end
  end

  test 'normalized articles have expected year' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal('2015', query['apinoaleph']['results'].first.year)
    end
  end

  test 'normalized articles have expected url' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal(
        'http://search.ebscohost.com/login.aspx?direct=true&site=eds-live&db=edsihs&AN=221456993819438',
        query['apinoaleph']['results'].first.url
      )
    end
  end

  test 'normalized articles have expected type' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal('Academic Journal',
                   query['apinoaleph']['results'].first.type)
    end
  end

  test 'normalized articles have expected authors' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcorn', 'apinoaleph')
      assert_equal(
        'Marques, Odair Jose',
        query['apinoaleph']['results'].first.authors.first
      )
      assert_equal(7, query['apinoaleph']['results'].first.authors.count)
    end
  end

  test 'searches with no results do not error' do
    VCR.use_cassette('no results',
                     allow_playback_repeats: true) do
      query = SearchEds.new.search('popcornandorangejuice', 'apinoaleph')
      assert_equal(0, query['apinoaleph']['total'])
    end
  end
end
