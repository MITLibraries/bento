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

  def initialize
    @attempts = 0
    @eds_http = HTTP.persistent(EDS_URL)
    @auth_token = uid_auth
    @results = {}
  end

  # Run a search, including creating and destroying EDS sessions.
  def search(term, profile, facets, page = 1, per_page = RESULTS_PER_BOX)
    # store passed parameters so we can retry later if we need to.
    @query = { term: term, profile: profile, facets: facets,
               page: page, per_page: per_page }
    return 'invalid credentials' unless @auth_token
    @session_key = create_session(profile) if @auth_token
    raw_results = search_filtered(term, facets, page, per_page)
    end_session
    raw_results
  end

  private

  # Clean search term to match EDS expectations
  # Commas cause problems as they seem to be interpreted as multiple params.
  def clean_term(term)
    URI.encode(term.strip.tr(' ', '+').tr(':', '%3A').delete(','))
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
                      .timeout(:global, write: http_timeout,
                                        connect: http_timeout,
                                        read: http_timeout)
                      .get(search_url(term, facets, page, per_page).to_s).to_s
    json_result = JSON.parse(result)
    detect_eds_errors(json_result)
    json_result
  end

  def detect_eds_errors(json_result)
    detect_and_recover_from_bad_eds_session(json_result)
    detect_general_eds_failure(json_result)
  end

  # Detect bad EDS session tokens and try again if we detect them.
  # However, we don't want to infinite loop so we have to keep track of
  # multiple consecutive failures and if we see them throw an exception.
  def detect_and_recover_from_bad_eds_session(json_result)
    prevent_multiple_retries
    return unless eds_session_invalid?(json_result)
    Rails.logger.warn('EDS API Session Token Invalid')
    retry_query
  end

  # Detect general EDS errors. Bad sessions still get special treatment in a
  # seprate method to allow us to try to recover. Detecting bad sessions must
  # be done prior to this method or this one will grab the bad sessions and not
  # retry.
  def detect_general_eds_failure(json_result)
    return if json_result.dig('ErrorDescription').blank?
    raise "EDS Error Detected: #{json_result.dig('ErrorDescription')}"
  end

  # Check the returned JSON for specific error state.
  def eds_session_invalid?(json_result)
    json_result.dig('ErrorDescription').present? &&
      json_result.dig('ErrorDescription') == 'Session Token Invalid'
  end

  # Attempt to do another search. A new session token is generated as part of
  # the `search` method.
  def retry_query
    Rails.logger.info('Retrying EDS Search')
    @attempts += 1
    search(@query[:term], @query[:profile], @query[:facets],
           @query[:page], @query[:per_page])
  end

  # Throw an exception if we have tried twice to do a search and both times
  # we had invalid session tokens. Users will receive a "try again later"
  # message and our Exception catcher will alert developers.
  def prevent_multiple_retries
    return unless @attempts > 1
    raise 'Multiple Consecutive Session Token Invalid Responses from EDS'
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
    (t / 3)
  end

  def uid_auth
    response = @eds_http.headers(accept: 'application/json').post(
      "#{EDS_URL}/authservice/rest/UIDAuth",
      json: { "UserId": ENV['EDS_USER_ID'], "Password": ENV['EDS_PASSWORD'] }
    ).flush
    return unless response.status == 200
    json_response = JSON.parse(response)
    json_response['AuthToken']
  end

  def create_session(profile)
    uri = [EDS_URL, '/edsapi/rest/CreateSession?profile=',
           profile, '&guest=n'].join('')
    response = @eds_http.headers(accept: 'application/json',
                                 "x-authenticationToken": @auth_token)
                        .get(uri).flush
    response.headers['X-Sessiontoken']
  end

  def end_session
    uri = [EDS_URL,
           '/edsapi/rest/endsession?sessiontoken=',
           URI.escape(@session_key).to_s].join('')
    @eds_http.headers(accept: 'application/json',
                      "x-authenticationToken": @auth_token,
                      'x-sessionToken': @session_key)
             .get(uri).flush
    @eds_http&.close
  end
end
