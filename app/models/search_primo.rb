# Searches Primosearch API and formats results into {Result} object
#
# == Required Environment Variables:
# - PRIMO_API_URL
# - PRIMO_API_KEY
# - PRIMO_VID
# - PRIMO_TAB
#

class SearchPrimo
  attr_reader :results

  PRIMO_API_URL = ENV['PRIMO_API_URL'].freeze
  PRIMO_API_KEY = ENV['PRIMO_API_KEY']
  PRIMO_VID = ENV['PRIMO_VID']
  PRIMO_TAB = ENV['PRIMO_TAB']

  def initialize
    @primo_http = HTTP.persistent(PRIMO_API_URL)
    @results = {}
  end

  def search(term, scope, per_page)
    result = @primo_http.timeout(http_timeout)
                        .headers(accept: 'application/json')
                        .get(search_url(term, scope, per_page))

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
  def search_url(term, scope, per_page)
    [PRIMO_API_URL, '/search?q=any,contains,', clean_term(term), '&vid=',
     PRIMO_VID, '&tab=', PRIMO_TAB, '&scope=', scope, '&limit=',
     per_page, '&apikey=', PRIMO_API_KEY].join('')
  end

  # https://github.com/httprb/http/wiki/Timeouts
  def http_timeout
    if ENV['PRIMO_TIMEOUT'].present?
      ENV['PRIMO_TIMEOUT'].to_f
    else
      6
    end
  end
end
