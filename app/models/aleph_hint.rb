# Parses Aleph marcxml and creates Hints
#
require 'open-uri'
class AlephHint
  def initialize
    @marcxml = marcxml
  end

  # Load aleph hint source as XML
  def marcxml
    Nokogiri::XML(open(Rails.application.secrets.aleph_hint_source))
  end

  # Selects the record nodes from the XML
  def records
    @marcxml.xpath('//xmlns:record')
  end

  # Loops over records and calls out to hint creation logic
  def process_records
    records.each do |record|
      record_to_hints(record)
    end
  end

  # Creates Hints for each record for each title and alt title
  # NOTE: at this time there is no detection of duplicates as that logic
  # may better reside in the Hint object itself to handle duplicates that may
  # originate from different loaders.
  def record_to_hints(record)
    Hint.create(title: title(record), url: best_url(record),
                fingerprint: Hint.fingerprint(title(record)))

    fingerprint_alt_titles(246, record)

    fingerprint_alt_titles(740, record)
  end

  # Creates a Hint for each alternate title
  def fingerprint_alt_titles(field, record)
    alt_titles(field, record).each do |alt_title|
      Hint.create(title: title(record), url: best_url(record),
                  fingerprint: Hint.fingerprint(alt_title))
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

  # For some reason, we sometimes use the standard 866$u for URLs but other
  # times use 956$u.
  def url(record)
    urls = []
    urls << extract_marc_value(956, 'u', record).map(&:text)
    urls << extract_marc_value(856, 'u', record).map(&:text)
    urls.flatten.compact.uniq
  end

  # Select the first Get URL from the array of urls
  # NOTE: the datasource was created by selecting records that contained
  # this url pattern so we make the assumption here that at least one url
  # should indeed match. Failure to maintain that contract will result in
  # an exception error during the loading of records.
  def best_url(record)
    url(record).select { |u| u.include?('libraries.mit.edu/get') }.first
  end
end
