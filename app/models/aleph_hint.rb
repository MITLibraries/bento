# Parses Aleph marcxml and creates Hints
#
require 'open-uri'
class AlephHint
  def initialize
    @marcxml = marcxml
    @source = 'aleph'
  end

  # Load aleph hint source as XML
  def marcxml
    Nokogiri::XML(open(Rails.application.secrets.aleph_hint_source))
  end

  # Selects the record nodes from the XML
  def records
    @marcxml.xpath('//xmlns:record')
  end

  # Deletes all Hints for the aleph source and reloads from the external source
  # @note rollback if any errors occur
  def reload
    ActiveRecord::Base.transaction do
      Hint.where(source: @source).delete_all
      process_records
    end
  end

  # Loops over records and calls out to hint creation logic
  def process_records
    records.each do |record|
      record_to_hints(record)
    end
  end

  # Creates Hints for each record for each title and alt title
  # @note duplicates are handled in the [Hint] model and are last one in wins
  def record_to_hints(record)
    title_like_fields.each do |field|
      fingerprint_titles(field[0], record)
    end
  end

  # MARC fields that contain title-like entries we will use to create
  # fingerprints
  # @see https://www.loc.gov/marc/bibliographic/bd20x24x.html
  # @see https://www.loc.gov/marc/bibliographic/bd70x75x.html
  def title_like_fields
    [
      [130, 'Uniform Title'],
      [210, 'Abbreviated Title'],
      # [222, 'Key Title'],
      [240, 'Uniform Title'],
      # [242, 'Translation of Title by Cataloging Agency'],
      # [243, 'Collective Uniform Title'],
      [245, 'Title Statement'],
      [246, 'Varying Form of Title'],
      # [247, 'Former Title'], # probably old records
      [730, 'Added Entry - Uniform Title'],
      [740, 'Added Entry - Uncontrolled Related/Analytical Title']
    ]
  end

  # Creates a Hint for each title
  def fingerprint_titles(field, record)
    alt_titles(field, record).each do |alt_title|
      # next if skip_urls(best_url(record))
      next if skip_fingerprints(Hint.fingerprint(alt_title))
      # Rails.logger.info('-----_____-----_____-----')
      # Rails.logger.info("Title #{title(record)}")
      # Rails.logger.info("URLs #{url(record)}")
      # Rails.logger.info("Fingerprint #{Hint.fingerprint(alt_title)}")
      Hint.upsert(title: title(record), url: best_url(record),
                  fingerprint: Hint.fingerprint(alt_title), source: @source)
    end
  end

  # skip common word fingerprints
  def skip_fingerprints(fingerprint)
    if %w[geography almanac protocols works synthesis update choice papers
          history music communication philosophy api bulletin archives ideas
          archaeology bookshelf congressional transport art physics power
          insurance proceedings].include?(fingerprint)
      true
    else
      false
    end
  end

  # Skip known problematic URLs
  def skip_urls(url)
    if ['/get/ecco', '/get/eiu', '/get/spie', '/get/mwr', '/get/wsmi',
        '/get/elib', '/get/crcnet', '/get/astmstand', '/get/wrds',
        '/get/glrc'].any? { |bad_url| url.include?(bad_url) }
      true
    else
      false
    end
  end

  # Extracts title from marc 245
  def title(record)
    extract_marc_value(245, 'a', record).text
  end

  # Extracts array of titles from supplied tag
  def alt_titles(tag, record)
    extract_marc_value(tag, 'a', record).map(&:text)
  end

  # Generic marc tag / subfield parser
  def extract_marc_value(tag, subfield, record)
    record.xpath(
      "./xmlns:datafield[@tag=#{tag}]/xmlns:subfield[@code=\"#{subfield}\"]"
    )
  end

  # For some reason, we sometimes use the standard 856$u for URLs but other
  # times use 956$u.
  def url(record)
    urls = []
    urls << extract_marc_value(956, 'u', record).map(&:text)
    urls << extract_marc_value(856, 'u', record).map(&:text)
    urls.flatten.compact.uniq
  end

  # Select the first Get URL from the array of urls
  # @note the datasource was created by selecting records that contained
  # this url pattern so we make the assumption here that at least one url
  # should indeed match. Failure to maintain that contract will result in
  # an exception error during the loading of records.
  def best_url(record)
    url(record).select { |u| u.include?('libraries.mit.edu/get') }.first
  end
end
