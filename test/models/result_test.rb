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
end
