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
    norm['primo_ui_view_more'] = primo_ui_view_more(q)
    extract_results(results, norm)
    norm
  rescue NoMethodError => e
    raise NormalizePrimo::InvalidResults,
          "Error: #{e}; Results: #{results}; Type: #{type}, q: #{q}"
  end

  private

  def primo_ui_view_more(q)
    [ENV['MIT_PRIMO_URL'], '/discovery/search?query=any,contains,', q,
     '&tab=bento&scope=', @type, '&vid=', ENV['PRIMO_VID']].join('')
  end

  def extract_results(results, norm)
    return unless results['docs']
    results['docs'].each do |record|
      result = result(record)
      norm['results'] << result
    end
  end

  def result(record)
    common = NormalizePrimoCommon.new(record, @type)
    result = Result.new(common.title, common.link)
    result = common.common_metadata(result)
    result = if @type == 'alma'
               NormalizePrimoBooks.new(record).book_metadata(result)
             else
               NormalizePrimoArticles.new(record).article_metadata(result)
             end
    result
  end
end
