class Tacos
  # Call TACOS to log search term and request information that TACOS knows about that term.
  # @param term [string] The string we are searching for
  # @return [Hash] A Hash listing detected suggested resources.
  def self.call(term)
    tacos_http = HTTP.persistent(TACOS_URL)
                      .headers(accept: 'application/json',
                               'Content-Type': 'application/json',
                               'Origin': ENV.fetch('ORIGINS', 'https://lib.mit.edu'))
    query = '{ "query": "{ search(searchterm: \"' + clean_term(term) + '\", sourceSystem: "bento" ) { phrase detectors { suggestedResources { title url } } } }" }'
    raw_response = tacos_http.timeout(http_timeout).post(TACOS_URL, body: query)
    JSON.parse(raw_response.to_s)
  end
end
