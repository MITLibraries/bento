# Loads our handcrafted hints. We collaborate on these in a google sheet, but
# we draw them from a separate CSV file rather than automatically from Sheets
# because the content of the google sheet is not guaranteed to be deployable -
# librarians use it as an active workspace - so we want them to take a specific
# action that indicates readiness before we ingest.
#
require 'csv'
require 'open-uri'
class CustomHint
  attr_reader :url

  def initialize(url)
    @url = url
    @csv = csv
    @source = 'custom'
  end

  # Load csv hint source.
  def csv
    open(@url, 'rb', &:read).force_encoding("UTF-8")
  end

  # Make sure the csv has the headers we expect. (More headers are fine - we'll
  # just ignore them - but it has to have these.)
  # This will raise an exception in the first line if the file can't be parsed
  # as CSV. We further validate that the CSV has the headers we'll need.
  def validate_csv
    mycsv = CSV.new(@csv, headers: true).read
    raise 'Invalid CSV - wrong headers' unless \
      %w(Title URL Example\ search).all? \
        { |header| mycsv.headers.include? header }
  end

  # Loop over records and create hints. Make sure to filter out blank data -
  # hand-created records may not have filled in all desired data, e.g. if there
  # is not an obvious result.
  def process_records
    validate_csv
    CSV.parse(@csv, headers: true) do |record|
      if %w(Title URL Example\ search).all? { |header| record[header].present? }
        record['Fingerprint'] = Hint.fingerprint(record['Example search'])
        Hint.upsert(title: record['Title'], url: record['URL'],
                    fingerprint: record['Fingerprint'], source: @source)
      end
    end
  end

  # Delete all Hints for the aleph source and reload from the external source.
  # Will rollback if any errors occur.
  def reload
    ActiveRecord::Base.transaction do
      Hint.where(source: @source).delete_all
      process_records
    end
  end
end
