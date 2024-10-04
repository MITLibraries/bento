class Tacos
  TACOS_URL = ENV.fetch('TACOS_URL', nil).freeze
  ORIGINS = ENV.fetch('ORIGINS', nil).freeze

  # Call TACOS to log search term and request information that TACOS knows about that term.
  # @param term [string] The string we are searching for
  # @return [Hash] A Hash listing detected suggested resources.
  def self.call(term)
    tacos_http = HTTP.persistent(TACOS_URL)
                     .headers(accept: 'application/json',
                              'Content-Type': 'application/json',
                              Origin: ORIGINS)
    query = '{ "query": "{ logSearchEvent(searchTerm: \"' + clean_term(term) + '\", sourceSystem: \"bento\" ) { phrase detectors { suggestedResources { title url } } } }" }'
    raw_response = tacos_http.timeout(http_timeout).post(TACOS_URL, body: query)
    JSON.parse(raw_response.to_s)
  end

  def self.clean_term(term)
    term.gsub('"', '\'')
  end

  def self.http_timeout
    ENV.fetch('TIMDEX_TIMEOUT', 6).to_f
  end
end
