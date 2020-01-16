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
    @query = '{"query":"{search(searchterm: \"' + term + '\", source: \"MIT ArchivesSpace\") {hits records {sourceLink title identifier publicationDate physicalDescription summary contributors { value } } } }"}'
    results = @timdex_http.post(TIMDEX_URL, :body => @query)
    json_result = JSON.parse(results.to_s)
  end
end
