# Tranforms results from {SearchGoogle} into normalized {Result}s
#
class NormalizeGoogle
  # Translate Google results into local result model
  def to_result(results)
    norm = {}
    norm['total'] = results.queries['request'][0]
                           .total_results.to_i
    norm['results'] = []
    extract_results(results, norm)
    norm
  end

  private

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
