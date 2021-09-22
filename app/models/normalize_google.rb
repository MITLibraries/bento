# Tranforms results from {SearchGoogle} into normalized {Result}s
#
class NormalizeGoogle
  # Translate Google results into local result model
  def to_result(results, q)
    norm = {}
    norm['total'] = results.queries.request[0].total_results.to_i
    norm['results'] = []
    norm['view_more'] = view_more(q)
    extract_results(results, norm)
    norm
  end

  private

  def view_more(q)
    "https://cse.google.com/cse?cx=#{ENV['GOOGLE_CUSTOM_SEARCH_ID']}" \
      "&ie=UTF-8&q=#{q}&sa=Search#gsc.tab=0&gsc.q=#{q}"
  end

  # Extract the information we care about from the raw results and add them
  # return them as an array of {result}s
  def extract_results(results, norm)
    return unless results.items
    results.items.each do |item|
      result = Result.new(item.title, item.link)
      result.blurb = item.html_snippet
      norm['results'] << result
    end
  end
end
