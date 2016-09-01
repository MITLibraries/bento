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
    @results['raw_google'] = @service.list_cses(
      term,
      cx: ENV['GOOGLE_CUSTOM_SEARCH_ID'],
      num: ENV['RESULTS_PER_BOX'] || 3
    )
    to_result(@results['raw_google'])
  end

  private

  # Translate Google results into local result model
  def to_result(results)
    norm = {}
    norm['total'] = @results['raw_google'].queries['request'][0]
                                          .total_results.to_i
    norm['results'] = []
    extract_results(results, norm)
    norm
  end

  # Extract the information we care about from the raw results and add them
  # return them as an array of {result}s
  def extract_results(results, norm)
    return unless results.items
    results.items.each do |item|
      result = Result.new(item.title, year_from_dc_modified(item),
                          item.link, 'website')
      norm['results'] << result
    end
  end

  # Extract year from dc.modified meta headers if available
  def year_from_dc_modified(item)
    return unless item.pagemap
    return unless item.pagemap['metatags']
    dc_mod = item.pagemap['metatags'][0]['dc.date.modified']
    return unless dc_mod
    Date.parse(dc_mod).year.to_s
  end
end
