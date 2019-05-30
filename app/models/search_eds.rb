# Searches EDS API and formats results into {Result} object
#
# == Required Environment Variables:
# - EDS_USER_ID
# - EDS_PASSWORD
# - EDS_URL
#
# == Optional Environment Variables:
# - RESULTS_PER_BOX
#
# == See Also
# - http://edswiki.ebscohost.com/EDS_API_Documentation
class SearchEds
  attr_reader :results

  EDS_URL = ENV['EDS_URL'].freeze
  RESULTS_PER_BOX = ENV['RESULTS_PER_BOX'] || 5
  EDS_SESSION_TIMEOUT = ENV['EDS_SESSION_TIMEOUT'] || 14
  EDS_AUTH_TIMEOUT = ENV['EDS_AUTH_TIMEOUT'] || 29

  def initialize
    @eds_http = HTTP.persistent(EDS_URL)
    @auth_token = cache_auth_token
    @results = {}
  end

  # Run a search, including creating and destroying EDS sessions.
  def search(term, profile, facets, page = 1, per_page = RESULTS_PER_BOX)
    # store passed parameters so we can retry later if we need to.
    @query = { term: term, profile: profile, facets: facets,
               page: page, per_page: per_page }
    raise 'EDS Error Detected: invalid credentials' unless @auth_token

    # If we ever start doing anything with pagination or facets, we will need
    # individual sessions per user. This is fine four the bento view needs now.
    @session_key = cache_session_token(profile)

    search_filtered(term, facets, page, per_page)
  end

  private

  # Clean search term to match EDS expectations
  # Commas cause problems as they seem to be interpreted as multiple params.
  def clean_term(term)
    URI.encode(term.strip.tr(' ', '+').delete(','))
  end

  def search_url(term, facets, page, per_page)
    [EDS_URL, '/edsapi/rest/Search?query=', clean_term(term),
     '&searchmode=all', "&resultsperpage=#{per_page}",
     "&pagenumber=#{page}", '&sort=relevance', '&highlight=n',
     '&includefacets=n', '&view=detailed', '&autosuggest=n',
     '&expander=fulltext', facets].join('')
  end

  def search_filtered(term, facets, page, per_page)
    result = @eds_http.headers(accept: 'application/json',
                               'x-authenticationToken': @auth_token,
                               'x-sessionToken': @session_key)
                      .timeout(http_timeout)
                      .get(search_url(term, facets, page, per_page).to_s)

    json_result = JSON.parse(result.to_s)

    if eds_session_invalid?(json_result)
      Rails.logger.warn('Clearing eds_session and eds_auth_token cache')
      Rails.cache.delete('eds_session')
      Rails.cache.delete('eds_auth_token')
    end

    raise "EDS Error Detected: #{json_result}" unless result.status == 200

    json_result
  end

  # Check the returned JSON for specific error state.
  def eds_session_invalid?(json_result)
    json_result.dig('ErrorDescription').present? &&
      json_result.dig('ErrorDescription') == 'Session Token Invalid'
  end

  # The timeout value is multiplied by 3 in http.rb so we divide by 3
  # here to end up with the timeout value we actually want.
  # This is because we are using a global (per request) timeout. It
  # is possible to instead separate out each phase of the request for
  # distinct timeouts if we find that is better.
  # https://github.com/httprb/http/wiki/Timeouts
  def http_timeout
    t = if ENV['EDS_TIMEOUT'].present?
          ENV['EDS_TIMEOUT'].to_f
        else
          6
        end
    t
  end

  def cache_auth_token
    Rails.cache.fetch('eds_auth_token', expires_in: EDS_AUTH_TIMEOUT.minutes,
                                        race_condition_ttl: 5) do
      uid_auth
    end
  end

  def uid_auth
    Rails.logger.info('Requesting EDS Auth Token')
    response = @eds_http.headers(accept: 'application/json')
                        .timeout(http_timeout)
                        .post("#{EDS_URL}/authservice/rest/UIDAuth",
                              json: { "UserId": ENV['EDS_USER_ID'],
                                      "Password": ENV['EDS_PASSWORD'] }).flush

    # prevent caching if bad response
    raise 'EDS Error: unable to get credentials' unless response.status == 200

    json_response = JSON.parse(response)

    # prevent caching if no token is present
    raise 'EDS Error: invalid credentials' unless json_response['AuthToken']

    json_response['AuthToken']
  end

  def cache_session_token(profile)
    Rails.cache.fetch('eds_session', expires_in: EDS_SESSION_TIMEOUT.minutes,
                                     race_condition_ttl: 5) do
      create_session(profile)
    end
  end

  def create_session(profile)
    Rails.logger.info('Requesting EDS Session Token')
    uri = [EDS_URL, '/edsapi/rest/CreateSession?profile=',
           profile, '&guest=n'].join('')
    response = @eds_http.headers(accept: 'application/json',
                                 "x-authenticationToken": @auth_token)
                        .timeout(http_timeout)
                        .get(uri).flush

    # prevent caching if bad response
    raise 'EDS Error: invalid session' unless response.status == 200

    # prevent caching if no token is present
    raise 'EDS Error: invalid session' unless response.headers['X-Sessiontoken']

    response.headers['X-Sessiontoken']
  end
end
