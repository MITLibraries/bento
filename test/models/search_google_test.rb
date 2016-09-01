require 'test_helper'
require 'google/apis/customsearch_v1'

class SearchGoogleTest < ActiveSupport::TestCase
  test 'valid google search with valid credentials returns results' do
    VCR.use_cassette('valid google search and credentials') do
      query = SearchGoogle.new.search('endnote')
      assert_equal(1610, query['total'])
    end
  end

  test 'invalid credentials' do
    VCR.use_cassette('invalid google credentials') do
      msg = assert_raises(Google::Apis::ClientError) do
        SearchGoogle.new.search('endnote')
      end
      assert_equal('keyInvalid: Bad Request', msg.message)
    end
  end

  test 'normalized results have expected title' do
    VCR.use_cassette('valid google search and credentials') do
      query = SearchGoogle.new.search('endnote')
      assert_equal(
        'EndNote with LaTeX & BibTeX - EndNote at MIT',
        query['results'].first.title.split[0...9].join(' ')
      )
    end
  end

  test 'normalized articles have expected year' do
    VCR.use_cassette('valid google search and credentials') do
      query = SearchGoogle.new.search('endnote')
      assert_equal('2016', query['results'].first.year)
    end
  end

  test 'normalized articles with no dc.date.modified have blank year' do
    VCR.use_cassette('valid google search and credentials') do
      query = SearchGoogle.new.search('endnote')
      assert_equal(nil, query['results'][2].year)
    end
  end

  test 'normalized articles have expected url' do
    VCR.use_cassette('valid google search and credentials') do
      query = SearchGoogle.new.search('endnote')
      assert_equal(
        'http://libguides.mit.edu/c.php?g=176170&p=1158648',
        query['results'].first.url
      )
    end
  end

  test 'normalized articles have expected type' do
    VCR.use_cassette('valid google search and credentials') do
      query = SearchGoogle.new.search('endnote')
      assert_equal('website', query['results'].first.type)
    end
  end

  test 'searches with no results do not error' do
    VCR.use_cassette('google no results') do
      query = SearchGoogle.new.search('asdffdsaasdffdsa')
      assert_equal(0, query['total'])
    end
  end

  test 'handles pages with no metadata' do
    VCR.use_cassette('google no metadata') do
      query = SearchGoogle.new.search('weather patterns')
      assert_equal(88, query['total'])
    end
  end
end
