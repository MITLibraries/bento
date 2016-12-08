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
  RESULTS_PER_BOX = ENV['RESULTS_PER_BOX'] || 3

  def initialize
    @auth_token = uid_auth
    @results = {}
  end

  def search(term, profile, facets)
    return 'invalid credentials' unless @auth_token
    @session_key = create_session(profile) if @auth_token
    raw_results = search_filtered(term, facets)
    end_session
    raw_results
  end

  private

  # Clean search term to match EDS expectations
  # Commas cause problems as they seem to be interpreted as multiple params.
  def clean_term(term)
    URI.encode(term.strip.tr(' ', '+').delete(','))
  end

  def search_url(term, facets)
    [EDS_URL, '/edsapi/rest/Search?query=', clean_term(term),
     '&searchmode=all', "&resultsperpage=#{RESULTS_PER_BOX}",
     '&pagenumber=1', '&sort=relevance', '&highlight=n', '&includefacets=n',
     '&view=detailed', '&autosuggest=n', '&expander=fulltext',
     facets].join('')
  end

  def search_filtered(term, facets)
    result = HTTP.headers(accept: 'application/json',
                          'x-authenticationToken': @auth_token,
                          'x-sessionToken': @session_key)
                 .get(search_url(term, facets).to_s).to_s
    JSON.parse(result)
  end

  def uid_auth
    response = HTTP.headers(accept: 'application/json').post(
      "#{EDS_URL}/authservice/rest/UIDAuth",
      json: { "UserId": ENV['EDS_USER_ID'], "Password": ENV['EDS_PASSWORD'] }
    )
    return unless response.status == 200
    json_response = JSON.parse(response)
    json_response['AuthToken']
  end

  def create_session(profile)
    uri = [EDS_URL, '/edsapi/rest/CreateSession?profile=',
           profile, '&guest=n'].join('')
    response = HTTP.headers(accept: 'application/json',
                            "x-authenticationToken": @auth_token)
                   .get(uri)
    response.headers['X-Sessiontoken']
  end

  def end_session
    uri = [EDS_URL,
           '/edsapi/rest/endsession?sessiontoken=',
           URI.escape(@session_key).to_s].join('')
    HTTP.headers(accept: 'application/json',
                 "x-authenticationToken": @auth_token,
                 'x-sessionToken': @session_key)
        .get(uri)
  end
end
