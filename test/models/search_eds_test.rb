require 'test_helper'

class SearchEdsTest < ActiveSupport::TestCase
  test 'valid search with valid credentials returns results' do
    VCR.use_cassette('valid search and credentials') do
      query = SearchEds.new.search('popcorn')
      assert_equal(2746, query['articles']['total'])
    end
  end

  test 'invalid credentials' do
    VCR.use_cassette('invalid credentials') do
      query = SearchEds.new.search('popcorn')
      assert_equal('invalid credentials', query)
    end
  end

  test 'normalized articles have expected title' do
    VCR.use_cassette('valid search and credentials') do
      query = SearchEds.new.search('popcorn')
      pp query['articles']['results'].first.title
      assert_equal(
        'Sowing time of popcorn during the summer harvest under',
        query['articles']['results'].first.title.split[0...9].join(' ')
      )
    end
  end

  test 'normalized articles have expected year' do
    VCR.use_cassette('valid search and credentials') do
      query = SearchEds.new.search('popcorn')
      assert_equal('2015', query['articles']['results'].first.year)
    end
  end

  test 'normalized articles have expected url' do
    VCR.use_cassette('valid search and credentials') do
      query = SearchEds.new.search('popcorn')
      assert_equal(
        'http://search.ebscohost.com/login.aspx?direct=true&site=eds-live&db=edsihs&AN=221456993819438',
        query['articles']['results'].first.url
      )
    end
  end

  test 'normalized articles have expected type' do
    VCR.use_cassette('valid search and credentials') do
      query = SearchEds.new.search('popcorn')
      assert_equal('Academic Journal', query['articles']['results'].first.type)
    end
  end

  test 'normalized articles have expected authors' do
    VCR.use_cassette('valid search and credentials') do
      query = SearchEds.new.search('popcorn')
      assert_equal(
        'Marques, Odair Jose',
        query['articles']['results'].first.authors.first
      )
      assert_equal(7, query['articles']['results'].first.authors.count)
    end
  end
end
