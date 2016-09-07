class SearchEds
  attr_reader :results

  EDS_URL = ENV['EDS_URL'].freeze
  RESULTS_PER_BOX = ENV['RESULTS_PER_BOX'] || 3

  def initialize
    @auth_token = uid_auth
    @results = {}
  end

  def search(term, profile)
    return 'invalid credentials' unless @auth_token
    @session_key = create_session(profile) if @auth_token
    @results["raw_#{profile}"] = search_filtered(term)
    end_session

    @results[profile.to_s] = to_result(@results["raw_#{profile}"])
    @results
  end

  private

  # Translate EDS results into local result model
  def to_result(results)
    norm = {}
    norm['total'] = results['SearchResult']['Statistics']['TotalHits']
    norm['results'] = []
    extract_results(results, norm)
    norm
  end

  def extract_results(results, norm)
    return unless results['SearchResult']['Data']['Records']
    results['SearchResult']['Data']['Records'].each do |record|
      record.extend Hashie::Extensions::DeepFind
      result = Result.new(title(record), year(record),
                          link(record), type(record))
      result.authors = authors(record)
      norm['results'] << result
    end
  end

  def title(record)
    bibentity = record['RecordInfo']['BibRecord']['BibEntity']
    bibentity['Titles'].first['TitleFull']
  end

  def year(record)
    relationships(record).deep_find('Y')
  end

  def link(record)
    record.deep_find('PLink')
  end

  def type(record)
    record.deep_find('PubType')
  end

  def authors(record)
    relationships(record).deep_find_all('NameFull')
  end

  def relationships(record)
    relationships = record['RecordInfo']['BibRecord']['BibRelationships']
    relationships.extend Hashie::Extensions::DeepFind
  end

  def search_url(term)
    [EDS_URL, '/edsapi/rest/Search?query=', URI.escape(term).to_s,
     '&searchmode=all', "&resultsperpage=#{RESULTS_PER_BOX}",
     '&pagenumber=1', '&sort=relevance', '&highlight=n', '&includefacets=n',
     '&view=brief', '&autosuggest=n'].join('')
  end

  def search_filtered(term)
    result = HTTP.headers(accept: 'application/json',
                          'x-authenticationToken': @auth_token,
                          'x-sessionToken': @session_key)
                 .get(search_url(term).to_s).to_s
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
