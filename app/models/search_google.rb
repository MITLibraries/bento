# Searches Google Custom Search and formats results into {Result} object
#
# == Required Environment Variables:
# - GOOGLE_API_KEY
# - GOOGLE_CUSTOM_SEARCH_ID
#
# == Optional Environment Variables:
# - RESULTS_PER_BOX
#
# == See Also
# - https://developers.google.com/custom-search/json-api/v1/overview
# - https://github.com/google/google-api-ruby-client
class SearchGoogle
  include Skylight::Helpers
  attr_reader :results
  require 'google/apis/customsearch_v1'

  def initialize
    cs = Google::Apis::CustomsearchV1
    @service = cs::CustomsearchService.new
    @service = Google::Apis::CustomsearchV1::CustomsearchService.new
    @service.key = ENV['GOOGLE_API_KEY']
    @results = {}
  end

  # Run a search
  # @param term [string] The string we are searching for
  # @return [Hash] A Hash with search metadata and an Array of {Result}s
  def search(term)
    @service.list_cses(
      term,
      cx: ENV['GOOGLE_CUSTOM_SEARCH_ID'],
      num: ENV['RESULTS_PER_BOX'] || 3
    )
  end
  instrument_method :search
end
