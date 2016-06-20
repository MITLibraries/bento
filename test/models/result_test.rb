require 'test_helper'

class ResultTest < ActiveSupport::TestCase
  test 'valid with all required elements' do
    r = Result.new('title', '1997', 'http://example.com', 'Journal Article')
    assert r.valid?
  end

  test 'invalid without title' do
    r = Result.new('', '1997', 'http://example.com', 'Journal Article')
    assert_not r.valid?
  end

  test 'invalid without year' do
    r = Result.new('title', '', 'http://example.com', 'Journal Article')
    assert_not r.valid?
  end

  test 'invalid without url' do
    r = Result.new('title', '1997', '', 'Journal Article')
    assert_not r.valid?
  end

  test 'invalid without type' do
    r = Result.new('title', '1997', 'http://example.com', '')
    assert_not r.valid?
  end

  test 'can set author' do
    r = Result.new('title', '1997', 'http://example.com', 'Journal Article')
    r.authors = 'Albatross, Joan'
    assert r.valid?
    assert_equal(r.authors, 'Albatross, Joan')
  end

  test 'can set citation' do
    r = Result.new('title', '1997', 'http://example.com', 'Journal Article')
    r.citation = 'Journal of Stuff, vol.12, no.1, pp.2-12'
    assert r.valid?
    assert_equal(r.citation, 'Journal of Stuff, vol.12, no.1, pp.2-12')
  end

  test 'can set online' do
    r = Result.new('title', '1997', 'http://example.com', 'Journal Article')
    r.online = true
    assert r.valid?
    assert_equal(r.online, true)
  end
end
