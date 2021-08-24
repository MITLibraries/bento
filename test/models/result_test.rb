require 'test_helper'

class ResultTest < ActiveSupport::TestCase
  test 'valid with all required elements' do
    r = Result.new('title', 'http://example.com')
    assert r.valid?
  end

  test 'invalid without title' do
    r = Result.new('', 'http://example.com')
    assert_not r.valid?
  end

  test 'invalid without url' do
    r = Result.new('title', '')
    assert_not r.valid?
  end

  test 'can set type' do
    r = Result.new('title', 'http://example.com')
    r.type = 'some type'
    assert r.valid?
    assert_equal(r.type, 'some type')
  end

  test 'can set year' do
    r = Result.new('title', 'http://example.com')
    r.year = 1997
    assert r.valid?
    assert_equal(r.year, 1997)
  end

  test 'can set author' do
    r = Result.new('title', 'http://example.com')
    r.authors = 'Albatross, Joan'
    assert r.valid?
    assert_equal(r.authors, 'Albatross, Joan')
  end

  test 'short author lists not truncated' do
    r = Result.new('title', 'http://example.com')
    r.authors = %w[a b]
    assert r.valid?
    assert_equal(r.truncated_authors, %w[a b])
  end

  test 'long author lists truncated' do
    r = Result.new('title', 'http://example.com')
    r.authors = %w[a b c d e]
    assert r.valid?
    assert_equal(r.truncated_authors, ['a', 'b', 'c', 'et al'])
  end

  test 'long subject lists truncated' do
    r = Result.new('title', 'http://example.com')
    r.subjects = %w[a b c d e]
    assert r.valid?
    assert_equal(r.subjects, %w[a b c d e])
    assert_equal(r.truncated_subjects, %w[a b c])
  end

  test 'long title trucated' do
    r = Result.new('title ' * 100, 'http://example.com')
    assert(r.title.length > 150)
    assert(r.truncated_title.length <= 150)
  end

  test 'long title not trucated mid word' do
    r = Result.new('title ' * 100, 'http://example.com')
    assert_equal('title...', r.truncated_title.split(' ').last)
  end

  test 'long physical description truncated' do
    r = Result.new('title', 'http://example.com')
    r.physical_description = 'physical ' * 100
    assert(r.physical_description.length > 200)
    assert(r.truncated_physical.length <= 200)
  end

  test 'can set citation' do
    r = Result.new('title', 'http://example.com')
    r.citation = 'Journal of Stuff, vol.12, no.1, pp.2-12'
    assert r.valid?
    assert_equal(r.citation, 'Journal of Stuff, vol.12, no.1, pp.2-12')
  end

  test 'can identify Alma records from accession number' do
    r = Result.new('title', 'http://example.com')
    r.an = 'alma9000000001'
    assert r.valid?
    assert r.alma_record?
  end

  test 'Primo full-text URLs map correctly to getit_url' do
    r = Result.new('title', 'http://example.com')
    r.openurl = 'https://mit.primo.exlibrisgroup.com/discovery/openurl?example'
    assert_equal r.getit_url, r.openurl
  end

  test 'Primo records without full-text URLs do not a have getit_url' do
    r = Result.new('title', 'http://example.com')
    assert_nil r.getit_url
  end
end
