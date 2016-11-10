require 'test_helper'

class NormalizeEdsBooksTest < ActiveSupport::TestCase
  def popcorn_books
    VCR.use_cassette('popcorn books',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('popcorn', 'apibarton')
      NormalizeEds.new.to_result(raw_query, 'books')
    end
  end

  test 'normalized books have expected title' do
    assert_equal(
      "Popcorn : fifty years of rock 'n' roll movies.",
      popcorn_books['results'].first.title
    )
  end

  test 'normalized books have expected link' do
    assert_equal(
      'http://search.ebscohost.com/login.aspx?direct=true&site=eds-live&db=cat01875a&AN=mittest.001739356',
      popcorn_books['results'].first.url
    )
  end

  test 'normalized books have expected authors' do
    assert_equal('Mulholland, Garry', popcorn_books['results'][0].authors[0][0])
  end

  test 'normalized books have expected author links' do
    assert_equal(
      'http://libproxy.mit.edu/login?url=https%3A%2F%2Fsearch.ebscohost.com%2Flogin.aspx%3Fdirect%3Dtrue%26AuthType%3Dcookie%2Csso%2Cip%2Cuid%26type%3D0%26group%3Dedstest%26profile%3Dedsbarton%26bquery%3DAU+%22Mulholland%2C+Garry%22',
      popcorn_books['results'][0].authors[0][1]
    )
  end

  test 'normalized books have expected multiple authors' do
    VCR.use_cassette('multiple book authors',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('vonnegut', 'apibarton')
      query = NormalizeEds.new.to_result(raw_query, 'books')
      assert_equal(
        ['Vonnegut, Kurt', 'Wakefield, Dan'],
        query['results'][0].authors.map { |a| a[0] }
      )
    end
  end

  test 'normalized books can handle no authors' do
    VCR.use_cassette('no book authors',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('orange', 'apibarton')
      query = NormalizeEds.new.to_result(raw_query, 'books')
      assert_nil(query['results'][0].authors)
    end
  end

  test 'normalized books have expected year' do
    assert_equal('2010', popcorn_books['results'].first.year)
  end

  test 'normalized books have expected type' do
    assert_equal('Book', popcorn_books['results'][0].type)
  end

  test 'normalized books have expected availability' do
    skip('need to determine logic to how this will work without misleading')
  end

  test 'normalized books have expected subjects' do
    assert_equal(
      'Rock films -- History and criticism',
      popcorn_books['results'][0].subjects[0][0]
    )
  end

  test 'normalized books have expected subject links' do
    assert_equal(
      'http://libproxy.mit.edu/login?url=https%3A%2F%2Fsearch.ebscohost.com%2Flogin.aspx%3Fdirect%3Dtrue%26AuthType%3Dcookie%2Csso%2Cip%2Cuid%26type%3D0%26group%3Dedstest%26profile%3Dedsbarton%26bquery%3DDE+%22Rock+films+--+History+and+criticism%22',
      popcorn_books['results'][0].subjects[0][1]
    )
  end

  test 'normalized books can handle no subjects' do
    assert_nil(popcorn_books['results'][1].subjects)
  end

  test 'normalized books can handle multiple subjects' do
    VCR.use_cassette('multiple book subjects',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('orange', 'apibarton')
      query = NormalizeEds.new.to_result(raw_query, 'books')
      assert_equal(4, query['results'][1].subjects.count)
    end
  end

  test 'normalized books have expected location' do
    assert_equal(
      [['Hayden Library - Stacks', 'PN1995.9.M86 M855 2010']],
      popcorn_books['results'].first.location
    )
  end

  test 'normalized books can have multiple locations' do
    assert_equal(4, popcorn_books['results'][1].location.count)
  end

  test 'normalized books can have no locations' do
    VCR.use_cassette('multiple book subjects',
                     allow_playback_repeats: true) do
      raw_query = SearchEds.new.search('orange', 'apibarton')
      query = NormalizeEds.new.to_result(raw_query, 'books')
      assert_nil(query['results'][1].location)
    end
  end

  test 'normalized books have expected publisher' do
    skip('eds data does not provide this data')
  end

  test 'normalized books have expected thumbnail' do
    assert_equal(
      'http://contentcafe2.btol.com/ContentCafe/jacket.aspx?UserID=ebsco-test&Password=ebsco-test&Return=T&Type=S&Value=9780752889351',
      popcorn_books['results'][0].thumbnail
    )
  end

  test 'normalized books can have no thumbnail' do
    assert_nil(popcorn_books['results'][1].thumbnail)
  end

  test 'normalized books do not have citation' do
    assert_nil(popcorn_books['results'][0].citation)
  end

  test 'normalized books do not have in' do
    assert_nil(popcorn_books['results'][0].in)
  end
end
