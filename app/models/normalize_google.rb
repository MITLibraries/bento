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
      result.year = year_from_dc_modified(item)
      result.type = 'website'
      norm['results'] << result
    end
  end

  # Extract year from dc.modified meta headers if available
  def year_from_dc_modified(item)
    return unless item.pagemap
    return unless item.pagemap['metatags']
    dc_mod = item.pagemap['metatags'][0]['dc.date.modified']
    return unless dc_mod
    Date.parse(dc_mod).year.to_s
  end
end
