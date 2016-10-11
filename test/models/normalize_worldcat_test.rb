require 'test_helper'

class NormalizeWorldcatTest < ActiveSupport::TestCase
  test 'normalized results have total results' do
    VCR.use_cassette('valid worldcat search and credentials') do
      raw_query = SearchWorldcat.new.search('popcorn')
      query = NormalizeWorldcat.new.to_result(raw_query)
      assert_equal(108, query['total'])
    end
  end

  test 'normalized results have expected title' do
    VCR.use_cassette('valid worldcat search and credentials') do
      raw_query = SearchWorldcat.new.search('popcorn')
      query = NormalizeWorldcat.new.to_result(raw_query)
      assert_equal('Popcorn Venus', query['results'].first.title)
    end
  end

  test 'normalized results have expected year' do
    VCR.use_cassette('valid worldcat search and credentials') do
      raw_query = SearchWorldcat.new.search('popcorn')
      query = NormalizeWorldcat.new.to_result(raw_query)
      assert_equal('1974, ©1973', query['results'].first.year)
    end
  end

  test 'normalized results have expected url' do
    VCR.use_cassette('valid worldcat search and credentials') do
      raw_query = SearchWorldcat.new.search('popcorn')
      query = NormalizeWorldcat.new.to_result(raw_query)
      assert_equal(
        'http://www.worldcat.org/oclc/1508955',
        query['results'].first.url
      )
    end
  end

  test 'normalized results have expected type' do
    VCR.use_cassette('valid worldcat search and credentials') do
      raw_query = SearchWorldcat.new.search('popcorn')
      query = NormalizeWorldcat.new.to_result(raw_query)
      assert_equal('worldcat', query['results'].first.type)
    end
  end

  test 'normalized results have expected authors' do
    VCR.use_cassette('valid worldcat search and credentials') do
      raw_query = SearchWorldcat.new.search('popcorn')
      query = NormalizeWorldcat.new.to_result(raw_query)
      assert_equal(['Rosen, Marjorie.'], query['results'].first.authors)
    end
  end

  test 'searches with no results do not error' do
    VCR.use_cassette('valid worldcat search no results') do
      raw_query = SearchWorldcat.new.search('asdfqeukaldk')
      query = NormalizeWorldcat.new.to_result(raw_query)
      assert_equal(0, query['total'])
    end
  end
end
