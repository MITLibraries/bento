class SearchEds
  attr_reader :results

  EDS_URL = ENV['EDS_URL'].freeze
  ARTICLES_FILTER = URI.escape(ENV['ARTICLES_FILTER']).freeze
  BOOKS_FILTER = URI.escape(ENV['BOOKS_FILTER']).freeze

  def initialize
    @auth_token = uid_auth
    @session_key = create_session if @auth_token
    @results = {}
  end

  def search(term)
    return 'invalid credentials' unless @auth_token
    @results['articles'] = search_filtered(term, ARTICLES_FILTER)
    @results['books'] = search_filtered(term, BOOKS_FILTER)
    end_session
    @results
  end

  private

  def search_url(term)
    [EDS_URL, '/edsapi/rest/Search?query=', URI.escape(term).to_s,
     '&searchmode=all', '&resultsperpage=3', '&pagenumber=1', '&sort=relevance',
     '&highlight=n', '&includefacets=n', '&view=brief',
     '&autosuggest=n'].join('')
  end

  def search_filtered(term, filter)
    result = HTTP.headers(accept: 'application/json',
                          'x-authenticationToken': @auth_token,
                          'x-sessionToken': @session_key)
                 .get("#{search_url(term)}#{filter}").to_s
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

  def create_session
    uri = [EDS_URL, '/edsapi/rest/CreateSession?profile=',
           ENV['EDS_PROFILE'], '&guest=n'].join('')
    response = HTTP.headers(accept: 'application/json',
                            "x-authenticationToken": @auth_token)
                   .get(uri)
    json_response = JSON.parse(response)
    json_response['SessionToken']
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
