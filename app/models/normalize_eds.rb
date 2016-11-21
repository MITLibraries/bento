# Tranforms results from {SearchEds} into normalized {Result}s
#
class NormalizeEds
  # Translate EDS results into local result model
  def to_result(results, type)
    @type = type
    norm = {}
    norm['total'] = results['SearchResult']['Statistics']['TotalHits']
    norm['results'] = []
    extract_results(results, norm)
    norm
  end

  private

  def extract_results(results, norm)
    return unless results['SearchResult']['Data']['Records']
    results['SearchResult']['Data']['Records'].each do |record|
      result = result(record)
      norm['results'] << result
    end
  end

  def result(record)
    common = NormalizeEdsCommon.new(record, @type)
    result = Result.new(common.title, common.link)
    result = common.common_metadata(result)
    result = if @type == 'books'
               NormalizeEdsBooks.new(record).book_metadata(result)
             else
               NormalizeEdsArticles.new(record).article_metadata(result)
             end
    result
  end
end
