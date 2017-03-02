require 'test_helper'

class ResultTest < ActiveSupport::TestCase
  def record_with_all_url_possibilities
    r = Result.new('title', 'http://example.org')
    r.marc_856 = 'http://example.org/this_is_a_marc856_link'
    r.custom_link = [{ 'Url' => 'http://sfx.mit.edu/example' },
                     { 'Url' => 'http://example.org/irrelevant_custom_link' }]
    r.openurl = 'http://example.org/constructed_open_url'
    r
  end

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
    r.authors = %w(a b)
    assert r.valid?
    assert_equal(r.truncated_authors, %w(a b))
  end

  test 'long author lists truncated' do
    r = Result.new('title', 'http://example.com')
    r.authors = %w(a b c d e)
    assert r.valid?
    assert_equal(r.truncated_authors, ['a', 'b', 'c', 'et al'])
  end

  test 'long subject lists truncated' do
    r = Result.new('title', 'http://example.com')
    r.subjects = %w(a b c d e)
    assert r.valid?
    assert_equal(r.subjects, %w(a b c d e))
    assert_equal(r.truncated_subjects, %w(a b c))
  end

  test 'can set citation' do
    r = Result.new('title', 'http://example.com')
    r.citation = 'Journal of Stuff, vol.12, no.1, pp.2-12'
    assert r.valid?
    assert_equal(r.citation, 'Journal of Stuff, vol.12, no.1, pp.2-12')
  end

  test 'can set online' do
    r = Result.new('title', 'http://example.com')
    r.online = true
    assert r.valid?
    assert_equal(r.online, true)
  end

  test 'flags MIT Aleph records' do
    r = Result.new('title', 'http://example.com')
    assert_equal(false, r.aleph_record?)

    r.an = 'mit.001739356'
    assert_equal(true, r.aleph_record?)
  end

  test 'can reformat aleph accession number' do
    r = Result.new('title', 'http://example.com')
    r.an = 'mit.001739356'
    assert_equal('MIT01001739356', r.clean_an)
  end

  test 'getit_url with marc_856' do
    r = record_with_all_url_possibilities
    assert_equal(r.marc_856, r.getit_url)
  end

  test 'getit_url with sfx custom_link' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    assert_equal('http://sfx.mit.edu/example', r.getit_url)
  end

  test 'getit_url with library custom_link' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.custom_link = [{ 'Url' => 'http://library.mit.edu/F/example' }]
    assert_equal('http://library.mit.edu/F/example', r.getit_url)
  end

  test 'getit_url with non sfx non library custom_link' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.openurl = nil
    r.custom_link = [{ 'Url' => 'http://example.org/irrelevant_custom_link' }]
    assert_equal('http://example.org', r.getit_url)
  end

  test 'getit_url with openurl' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.custom_link = nil
    assert_equal('http://example.org/constructed_open_url', r.getit_url)
  end

  test 'getit_url with only url' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.custom_link = nil
    r.openurl = nil
    assert_equal('http://example.org', r.getit_url)
  end
end
