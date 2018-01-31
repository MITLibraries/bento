require 'test_helper'

include RecordHelper

class RecordHelperTest < ActionView::TestCase
  test 'clean_language case 1' do
    mock_record = stub(:eds_languages => 'English, Russian')
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['English', 'Russian'], controller.clean_language)
  end

  test 'clean_language case 2' do
    mock_record = stub(:eds_languages => ['English', 'Russian'])
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['English', 'Russian'], controller.clean_language)
  end

  test 'clean_language case 3' do
    mock_record = stub(:eds_languages => 'English')
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['English'], controller.clean_language)
  end

  test 'clean_language case 4' do
    mock_record = stub(:eds_languages => ['English'])
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['English'], controller.clean_language)
  end

  test 'clean_affiliations' do
    affiliations = <<-DOC
    <relatesTo>1</relatesTo>Small
            Systems Laboratory, Department of Mechanical Engineering, Worcester Polytechnic
            Institute, Worcester, MA 01532, USA
DOC
    affiliations = affiliations.gsub(/\s+/, " ").strip
    mock_record = stub(:eds_author_affiliations => affiliations)
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['Small Systems Laboratory, Department of Mechanical Engineering, Worcester Polytechnic Institute, Worcester, MA 01532, USA'],
                  controller.clean_affiliations)

  end

  test 'clean_other_titles' do
    titles = <<-DOC
    <searchLink fieldCode="TI" term="%22Jungle+capitalists%22">
    Jungle capitalists</searchLink>
DOC
    titles = titles.gsub(/\s+/, " ").strip
    mock_record = stub(:eds_other_titles => titles)
    controller.instance_variable_set(:@record, mock_record)

    assert_equal(['Jungle capitalists'],
                  controller.clean_other_titles)

  end

  test 'link with a domain in relevant links' do
    link = { url: 'https://libraries.mit.edu/F/stuff' }
    assert(relevant_fulltext_link?(link))
  end

  test 'link without a domain in relevant links' do
    link = { url: 'https://loc.gov/toc/because/whynot' }
    refute(relevant_fulltext_link?(link))
  end

  test 'force_https with http url changes to https' do
    assert_equal('https://example.com/yo', force_https('http://example.com/yo'))
  end

  test 'force_https with https url' do
    assert_equal('https://example.com/yo',
                 force_https('https://example.com/yo'))
  end

  test 'force_https with no scheme returns input unchanged' do
    assert_equal('example.com/yo', force_https('example.com/yo'))
  end

  test 'detects subjects we should not scan' do
    @subjects = ['Materials -- Standards -- United States -- Periodicals']
    assert_equal(false, scan?)
  end

  test 'detects subjects we should not scan when included with those we do' do
    @subjects = ['yo',
                 'Materials -- Standards -- United States -- Periodicals',
                 'Another -- non-excluded -- subject']
    assert_equal(false, scan?)
  end

  test 'does not exclude subjects we do scan' do
    @subjects = ['yo']
    assert_equal(true, scan?)
  end

  test 'handles nil subjects when checking for scan exclusion' do
    @subjects = nil
    assert_equal(true, scan?)
  end

  test 'weird stuff in subjects' do
    @subjects = 'not an array'
    assert_equal(true, scan?)
  end

  test 'no excluded subjects defined' do
    stored_env = ENV['SCAN_EXCLUSIONS']
    ENV.delete('SCAN_EXCLUSIONS')
    @subjects = ['yo']
    assert_equal(true, scan?)
    ENV['SCAN_EXCLUSIONS'] = stored_env
  end

  test 'maps EDS pub type to Zotero pub type' do
    mock_record = stub(:eds_publication_type => 'Academic Journal')
    assert_equal(map_record_type(mock_record), 'Journal Article')
  end

  test 'uses EDS pub type when no mapping exists' do
    mock_record = stub(:eds_publication_type => 'Unhinged Lunacy')
    assert_equal(map_record_type(mock_record), 'Unhinged Lunacy')
  end

  test 'no summary holdings in serial note' do
    serial_note = 'yo I like yoyos yo.'
    assert_equal([], summary_holdings(serial_note))
  end

  test 'just summary holdings in serial note' do
    serial_note = '[s_h] do you like yoyos?'
    assert_equal(['do you like yoyos?'], summary_holdings(serial_note))
  end

  test 'summary holdings and notes in serial note' do
    serial_note = 'yo I like yoyos yo. [s_h] do you like yoyos?'
    assert_equal(['do you like yoyos?'], summary_holdings(serial_note))
  end

  test 'mutiple summary holdings and notes in serial note' do
    serial_note = 'yo I like yoyos yo. [s_h] do you like yoyos? [s_h] naptime'
    assert_equal(['do you like yoyos?',
                  'naptime'], summary_holdings(serial_note))
  end

  test 'mutiple summary holdings and no note in serial note' do
    serial_note = '[s_h] do you like yoyos? [s_h] naptime'
    assert_equal(['do you like yoyos?',
                  'naptime'], summary_holdings(serial_note))
  end

  test 'nothing in serial note' do
    serial_note = ''
    assert_equal([], summary_holdings(serial_note))
  end
end
