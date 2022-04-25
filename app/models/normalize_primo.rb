# Tranforms results from {SearchPrimo} into normalized {Result}s
#
class NormalizePrimo
  class InvalidResults < StandardError; end

  # Translate Primo results into local result model
  def to_result(results, type, q)
    @type = type
    norm = {}
    norm['total'] = results['info']['total']
    norm['results'] = []
    norm['view_more'] = view_more(q)
    extract_results(results, norm, q)
    norm
  rescue NoMethodError => e
    raise NormalizePrimo::InvalidResults,
          "Error: #{e}; Results: #{results}; Type: #{type}, q: #{q}"
  end

  private

  def view_more(q)
    [ENV['MIT_PRIMO_URL'], '/discovery/search?query=any,contains,', q,
     '&tab=', ENV['PRIMO_MAIN_VIEW_TAB'], '&search_scope=', @type, '&vid=',
     ENV['PRIMO_VID']].join('')
  end

  def extract_results(results, norm, q)
    return unless results['docs']

    results['docs'].each do |record|
      result = result(record, q)
      norm['results'] << result
    end
  end

  def result(record, q)
    common = NormalizePrimoCommon.new(record, @type)
    result = Result.new(common.title, common.link)
    result = common.common_metadata(result)
    if @type == ENV['PRIMO_BOOK_SCOPE']
      NormalizePrimoBooks.new(record, q).book_metadata(result)
    else
      NormalizePrimoArticles.new(record).article_metadata(result)
    end
  end
end
