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

  def locations
    [['Institute Archives - Noncirculating Collection 3', 'call number'],
     ['Hayden Library - Stacks', 'call number'],
     ['Library Storage Annex - Off Campus Collection', 'call number'],
     ['Hayden Library - Science Oversize Materials', 'call number'],
     ['Institute Archives - Microforms', 'call number'],
     ['Hayden Library - Humanities Microforms', 'call number'],
     ['Hayden Library - Browsery', 'call number'],
     ['Lewis Music Library - Media', 'call number'],
     ['Dewey Library - Microforms', 'call number'],
     ['Hayden Library - Humanities Media', 'call number']]
  end

  test 'returns hayden location first' do
    r = Result.new('title', 'http://example.com')
    r.location = locations
    assert_equal('Hayden Library - Stacks', r.prioritized_location[0][0])
  end
end
