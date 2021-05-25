require 'test_helper'

class ResultTest < ActiveSupport::TestCase
  def record_with_all_url_possibilities
    r = Result.new('title', 'http://example.org')
    r.marc_856 = 'http://sfx.mit.edu/marc856_example'
    r.fulltext_links = [
      { 'Url' => 'http://sfx.mit.edu/example' },
      { 'Url' => 'http://example.org/irrelevant_custom_link' }
    ]
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

  test 'flags MIT Course Reserve records' do
    r = Result.new('title', 'http://example.com')
    assert_equal(false, r.aleph_record?)

    r.an = 'mitcr.001739356'
    assert_equal(true, r.aleph_cr_record?)
  end

  test 'can reformat aleph accession number' do
    r = Result.new('title', 'http://example.com')
    r.an = 'mit.001739356'
    assert_equal('MIT01001739356', r.clean_an)
  end

  test 'can reformat aleph Course Reserve accession number' do
    r = Result.new('title', 'http://example.com')
    r.an = 'mitcr.001739356'
    assert_equal('MIT30001739356', r.clean_an)
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
    r.fulltext_links = [{ 'Url' => 'http://library.mit.edu/F/example' }]
    assert_equal('http://library.mit.edu/F/example', r.getit_url)
  end

  test 'getit_url with owens custom_link' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.fulltext_links = [{ 'Url' => 'http://owens.mit.edu/stuff' }]
    assert_equal('http://owens.mit.edu/stuff', r.getit_url)
  end

  test 'getit_url with non sfx non library custom_link' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.openurl = nil
    r.fulltext_links = [{ 'Url' => 'http://example.org/irrelevant_customlink' }]
    assert_nil(r.getit_url)
  end

  test 'getit_url with only url' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.fulltext_links = nil
    r.openurl = nil
    assert_nil(r.getit_url)
  end

  test 'getit_url with library.mit.edu url' do
    r = record_with_all_url_possibilities
    r.marc_856 = 'http://library.mit.edu/F/this_is_a_marc856_link'
    assert_equal('http://library.mit.edu/F/this_is_a_marc856_link', r.getit_url)
  end

  test 'getit_url with libraries.mit.edu url' do
    r = record_with_all_url_possibilities
    r.marc_856 = 'http://libraries.mit.edu/get/stuff'
    assert_equal('http://libraries.mit.edu/get/stuff', r.getit_url)
  end

  test 'getit_url with irrelevant marc_856 url' do
    r = record_with_all_url_possibilities
    r.marc_856 = 'http://example.org/this_is_a_marc856_link'
    r.fulltext_links = nil
    r.openurl = nil
    assert_nil(r.getit_url)
  end

  test 'getit_url with sfx and proxied sd links uses sd' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.fulltext_links = [
      { 'Url' => 'http://sfx.mit.edu/example' },
      { 'Url' => 'http://libproxy.mit.edu/somestuff' }
    ]
    r.openurl = nil
    assert_equal('http://libproxy.mit.edu/somestuff', r.getit_url)

    r.fulltext_links = [
      { 'Url' => 'http://sfx.mit.edu/example' },
      { 'Url' => 'http://example.com/example' },
      { 'Url' => 'http://libproxy.mit.edu/somestuff' },
      { 'Url' => 'http://sfx.mit.edu/example' }
    ]
    assert_equal('http://libproxy.mit.edu/somestuff', r.getit_url)
  end

  test 'getit_url with only non-subscribed sfx link' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.fulltext_links = [
      { 'Url' => 'http://sfx.mit.edu/example',
        'Name' => 'SFX link (not subscribed resources)' }
    ]
    r.openurl = nil
    assert_nil(r.getit_url)
  end

  test 'getit_url with subscribed and non-subscribed sfx links' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.fulltext_links = [
      { 'Url' => 'http://sfx.mit.edu/example',
        'Name' => 'SFX link (not subscribed resources)' },
      { 'Url' => 'http://sfx.mit.edu/hi_mom' }
    ]
    r.openurl = nil
    assert_equal('http://sfx.mit.edu/hi_mom', r.getit_url)
  end

  test 'check_sfx_url with non-subscribed link' do
    r = record_with_all_url_possibilities
    r.marc_856 = nil
    r.fulltext_links = [
      { 'Url' => 'http://sfx.mit.edu/example',
        'Name' => 'SFX link (not subscribed resources)' }
    ]
    r.openurl = nil
    assert_nil(r.getit_url)
    assert_equal('http://sfx.mit.edu/example', r.check_sfx_url)
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

  test 'Availabilty is evaluated as expected' do
    r = Result.new('title', 'http://example.com')
    r.availability_status = ['available']
    assert r.available?

    r.availability_status = ['available', 'unavailable']
    assert r.available?

    r.availability_status = ['unavailable']
    assert_not r.available?

    r.availability_status = ['foo']
    assert_not r.available?

    r.availability_status = ['check_holdings']
    assert_not r.available?
    assert r.check_holdings?
  end
end
