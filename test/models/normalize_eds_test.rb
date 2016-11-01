require 'test_helper'

class NormalizeEdsTest < ActiveSupport::TestCase
  test 'normalized articles have expected title' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query, 'articles')
      assert_equal(
        'History of northern corn leaf blight disease in the',
        query['results'].first.title.split[0...9].join(' ')
      )
    end
  end

  test 'normalized articles have expected year' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query, 'articles')
      assert_equal('2016', query['results'].first.year)
    end
  end

  test 'normalized articles have expected url' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query, 'articles')
      assert_equal(
        'https://sfx.mit.edu/sfx_local?rfr_id=info%3Asid%2FMIT.BENTO&rft.au=Moreira+Ribeiro%2C+Rodrigo%3Bdo+Amaral+J%C3%BAnior%2C+Ant%C3%B4nio+Teixeira%3BFerreira+Pena%2C+Guilherme%3BVivas%2C+Marcelo%3BNascimento+Kurosawa%2C+Railan%3BAzeredo+Gon%C3%A7alves%2C+Leandro+Sim%C3%B5es&rft.issue=4&rft.jtitle=Acta+Scientiarum%3A+Agronomy&rft.volume=38&rft.year=2016&rft_id=info%3Adoi%2F10.4025%2Factasciagron.v38i4.30573',
        query['results'].first.url
      )
    end
  end

  test 'normalized articles have expected type' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query, 'articles')
      assert_equal('Academic Journal', query['results'].first.type)
    end
  end

  test 'normalized articles have expected authors' do
    VCR.use_cassette('popcorn articles',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apinoaleph')
      query = NormalizeEds.new.to_result(raw_query, 'articles')
      assert_equal(
        'Moreira Ribeiro, Rodrigo',
        query['results'].first.authors.first
      )
      assert_equal(6, query['results'].first.authors.count)
    end
  end

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
end
