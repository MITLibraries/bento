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
    fingerprint_titles(245, record)
    fingerprint_titles(246, record)
    fingerprint_titles(740, record)
  end

  # Creates a Hint for each title
  def fingerprint_titles(field, record)
    alt_titles(field, record).each do |alt_title|
      Hint.upsert(title: title(record), url: best_url(record),
                  fingerprint: Hint.fingerprint(alt_title), source: @source)
    end
  end

  # Extracts title from marc 245
  def title(record)
    extract_marc_value(245, 'a', record).text
  end

  # Extracts array of alternate titles from supplied tag (246 and 740)
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
