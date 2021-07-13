# Searches TIMDEX! API and formats results into {Result} object
#
# == Required Environment Variables:
# - TIMDEX_URL
#
# == See Also
# - https://timdex.mit.edu/playground
class SearchTimdex
  attr_reader :results

  TIMDEX_URL = ENV['TIMDEX_URL'].freeze

  def initialize
    @timdex_http = HTTP.persistent(TIMDEX_URL)
      .headers(accept: 'application/json',
        'Accept-Encoding': 'gzip, deflate, br',
        'Content-Type': 'application/json',
        'Origin': 'https://lib.mit.edu'
      )
    @results = {}
  end

  # Run a search
  # @param term [string] The string we are searching for
  # @return [Hash] A Hash with search metadata and an Array of {Result}s
  def search(term)
    @query = '{"query":"{search(searchterm: \"' + clean_term(term) + '\", source: \"MIT ArchivesSpace\") {hits records {sourceLink title identifier publicationDate physicalDescription summary contributors { value } } } }"}'
    results = @timdex_http.timeout(http_timeout)
                          .post(TIMDEX_URL, :body => @query)
    json_result = JSON.parse(results.to_s)
  end

  def clean_term(term)
    term.gsub('"', '\'')
  end

  private

  # https://github.com/httprb/http/wiki/Timeouts
  def http_timeout
    t = if ENV['TIMDEX_TIMEOUT'].present?
          ENV['TIMDEX_TIMEOUT'].to_f
        else
          6
        end
    t
  end
end
