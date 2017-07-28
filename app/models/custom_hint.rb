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
require 'open-uri'
class CustomHint
  def initialize
    @csv = csv
    @source = 'custom'
  end

  # Load csv hint source.
  # The ?dl=1 is important here; if you set ?dl=0 it will GET the HTML version
  # rendered on dropbox.com, whereas ?dl=1 just downloads the file.
  # todo THIS IS NOT THE PRODUCTION URL - it's a testing URL while we decide
  # on production.
  def csv
    open('https://www.dropbox.com/s/jfktzf4yzi1yhg4/bento_loader_test.csv?dl=1') {|f| f.read }
  end

  # Make sure the csv has the headers we expect. (More headers are fine - we'll
  # just ignore them - but it has to have these.)
  def is_valid?
    mycsv = CSV.new(@csv, :headers => true).read
    %w{Title URL Fingerprint}.all? { |title| mycsv.headers.include? title }
  end

  # Loop over records and create hints.
  def process_records
    return unless is_valid?
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
