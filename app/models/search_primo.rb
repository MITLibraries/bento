# Searches Primosearch API and formats results into {Result} object
#
# == Required Environment Variables:
# - PRIMO_SEARCH_API_URL
# - PRIMO_SEARCH_API_KEY
# - PRIMO_VID
#

class SearchPrimo
  attr_reader :results

  PRIMO_SEARCH_API_URL = ENV['PRIMO_SEARCH_API_URL'].freeze
  PRIMO_SEARCH_API_KEY = ENV['PRIMO_SEARCH_API_KEY']
  PRIMO_VID = ENV['PRIMO_VID']

  def initialize
    @primo_http = HTTP.persistent(PRIMO_SEARCH_API_URL)
    @results = {}
  end

  def search(term, scope)
    result = @primo_http.headers(accept: 'application/json')
                        .get(search_url(term, scope))

    raise "Primo Error Detected: #{result.status}" unless result.status == 200

    JSON.parse(result)
  end

  private

  # Initial search term sanitization.
  def clean_term(term)
    URI.encode(term.strip.tr(' ', '+').delete(',').tr(':', '+'))
  end

  # This is subject to change. Right now we are just using the required 
  # params and assuming that no operators are used.
  def search_url(term, scope)
    [PRIMO_SEARCH_API_URL, '/primo/v1/search?q=any,contains,', 
      clean_term(term), '&vid=', PRIMO_VID, '&tab=bento&scope=', scope,
      '&apikey=', PRIMO_SEARCH_API_KEY].join('')
  end
end
