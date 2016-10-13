# Searches WorldCat Search API and formats results into {Result} object
#
# == Required Environment Variables:
# - WORLDCAT_API_KEY
# - WORLDCAT_URI
#
# == Optional Environment Variables:
# - RESULTS_PER_BOX
#
# == See Also
# - https://platform.worldcat.org/api-explorer/apis/wcapi
# - http://www.oclc.org/developer/develop/web-services/worldcat-search-api.en.html
class SearchWorldcat
  attr_reader :results

  def initialize
    @results = {}
  end

  # Run a search
  # @param term [string] The string we are searching for
  # @return [Hash] A Hash with search metadata and an Array of {Result}s
  def search(term)
    HTTP.get(search_url(clean_term(term)))
  end

  def search_url(term)
    "#{ENV['WORLDCAT_URI']}" \
    "sru?query=srw.kw+any+%22#{term}%22" \
    '+and+srw.li+any+%22MYG%22' \
    '&recordSchema=info%3Asrw%2Fschema%2F1%2Fdc' \
    "&wskey=#{ENV['WORLDCAT_API_KEY']}" \
    "&maximumRecords=#{ENV['RESULTS_PER_BOX'] || 3}"
  end

  def clean_term(term)
    URI.encode(term.strip.tr(' ', '+'))
  end
end
