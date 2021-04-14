# Searches Primosearch API and formats results into {Result} object
#
# == Required Environment Variables:
# - PRIMO_SEARCH_API_URL
# - PRIMO_SEARCH_API_KEY
# - PRIMO_VID_INST
#

class SearchPrimo
  attr_reader :results

  PRIMO_SEARCH_API_URL = ENV['PRIMO_SEARCH_API_URL'].freeze
  PRIMO_SEARCH_API_KEY = ENV['PRIMO_SEARCH_API_KEY']
  PRIMO_VID_INST = ENV['PRIMO_VID_INST']

  def initialize
    @primo_http = HTTP.persistent(PRIMO_SEARCH_API_URL)
    @results = {}
  end

  def search(term)
    result = @primo_http.headers(accept: 'application/json')
                        .get(search_url(term))

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
  def search_url(term)
    [PRIMO_SEARCH_API_URL, '/primo/v1/search?vid=', PRIMO_VID_INST,
     '&tab=Everything&scope=default_scope&q=any,contains,', clean_term(term),
     '&inst=', PRIMO_VID_INST, '&apikey=', PRIMO_SEARCH_API_KEY].join('')
  end
end
