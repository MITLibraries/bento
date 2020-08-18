require 'test_helper'
require 'google/apis/customsearch_v1'

class NormalizeGoogleTest < ActiveSupport::TestCase
  test 'normalized results have expected title' do
    VCR.use_cassette('valid google search and credentials') do
      raw_query = SearchGoogle.new.search('endnote')
      query = NormalizeGoogle.new.to_result(raw_query, 'endnote')
      assert_equal(
        'EndNote - Citation Management and Writing Tools - LibGuides',
        query['results'].first.title.split[0...9].join(' ')
      )
    end
  end

  test 'normalized articles have expected url' do
    VCR.use_cassette('valid google search and credentials') do
      raw_query = SearchGoogle.new.search('endnote')
      query = NormalizeGoogle.new.to_result(raw_query, 'endnote')
      assert_equal(
        'https://libguides.mit.edu/endnote',
        query['results'].first.url
      )
    end
  end

  test 'normalized articles have expected snippet' do
    VCR.use_cassette('valid google search and credentials') do
      raw_query = SearchGoogle.new.search('endnote')
      query = NormalizeGoogle.new.to_result(raw_query, 'endnote')
      assert_includes(query['results'].first.blurb,
                      'help with citation management')
    end
  end

  test 'searches with no results do not error' do
    VCR.use_cassette('google no results') do
      raw_query = SearchGoogle.new.search('asdffdsaasdffdsa')
      query = NormalizeGoogle.new.to_result(raw_query, 'asdffdsaasdffdsa')
      assert_equal(0, query['total'])
    end
  end

  test 'handles pages with no metadata' do
    VCR.use_cassette('google no metadata') do
      raw_query = SearchGoogle.new.search('weather patterns')
      query = NormalizeGoogle.new.to_result(raw_query, 'weather patterns')
      assert_equal(3, query['total'])
    end
  end
end
