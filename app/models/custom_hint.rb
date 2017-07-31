# Loads our handcrafted hints. We collaborate on these in a google sheet, but
# we draw them from a separate CSV file rather than automatically from Sheets
# for two reasons:
#  1) to avoid having a production app have reliance on a developer's personal
#     API key
#  2) because the content of the google sheet is not guaranteed to be
#     deployable - librarians use it as an active workspace - so we want them
#     to take a specific action that indicates readiness before we ingest.
#
require 'csv'
require 'uri'
require 'open-uri'
class CustomHint
  def initialize(url)
    @url = url
    @csv = csv
    @source = 'custom'
  end

  # If a dropbox URL ends in ?dl=1, it downloads the file; if it ends in ?dl=0,
  # it renders the file as HTML. We want to make sure we download the file, but
  # the copy-link version gives the render-page option by default, so let's
  # recover gracefully in that case.
  def canonicalize_url
    as_uri = URI(@url)           # Will raise exception for non-URL strings
    if as_uri.query == 'dl=0'
      as_uri.query = 'dl=1'
    end
    @url = as_uri.to_s
  end

  def validate_url
    as_uri = URI(@url)
    raise "Invalid URL - not a Dropbox download URL" unless [
      @url =~ URI::regexp,                # It is a valid URL
      as_uri.host == 'www.dropbox.com',   # ...from Dropbox
      as_uri.query == 'dl=1'              # ...which triggers a file download
    ].all?
  end

  # Load csv hint source.
  def csv
    open(@url) {|f| f.read }
  end

  # Make sure the csv has the headers we expect. (More headers are fine - we'll
  # just ignore them - but it has to have these.)
  # This will raise an exception in the first line if the file can't be parsed
  # as CSV. We further validate that the CSV has the headers we'll need.
  def validate_csv
    mycsv = CSV.new(@csv, :headers => true).read
    raise "Invalid CSV - wrong headers" unless \
      %w{Title URL Fingerprint}.all? { |title| mycsv.headers.include? title }
  end

  # Loop over records and create hints.
  def process_records
    canonicalize_url
    validate_url
    validate_csv
    CSV.parse(@csv, :headers => true) do |record|
      Hint.upsert(title: record['Title'], url: record['URL'],
                  fingerprint: record['Fingerprint'], source: @source)
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
