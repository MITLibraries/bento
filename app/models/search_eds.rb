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
    @results['raw_articles'] = search_filtered(term, ARTICLES_FILTER)
    @results['raw_books'] = search_filtered(term, BOOKS_FILTER)
    end_session
    @results['articles'] = to_result(@results['raw_articles'])
    @results['books'] = to_result(@results['raw_books'])
    @results
  end

  private

  # Translate EDS results into local result model
  def to_result(results)
    results.extend Hashie::Extensions::DeepFind
    norm = {}
    norm['total'] = results.deep_find('TotalHits')
    norm['results'] = []
    extract_results(results, norm)
    norm
  end

  def extract_results(results, norm)
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
