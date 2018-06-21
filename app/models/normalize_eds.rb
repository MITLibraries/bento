# Tranforms results from {SearchEds} into normalized {Result}s
#
class NormalizeEds
  class InvalidResults < StandardError; end

  # Translate EDS results into local result model
  def to_result(results, type, q)
    @type = type
    norm = {}
    norm['total'] = results['SearchResult']['Statistics']['TotalHits']
    norm['results'] = []
    norm['eds_ui_view_more'] = eds_ui_view_more(q)
    norm['local_view_more'] = local_view_more(q)
    extract_results(results, norm)
    norm
  rescue NoMethodError => e
    raise NormalizeEds::InvalidResults,
          "Error: #{e}; Results: #{results}; Type: #{type}, q: #{q}"
  end

  private

  def local_view_more(q)
    Rails.application.routes.url_helpers.search_path(q: q, target: @type)
  end

  def eds_ui_view_more(q)
    "#{ENV['EDS_PROFILE_URI']}#{q}&facet=#{facets_list}"
  end

  def facets_list
    facets.gsub('&facetfilter=1,', '').split(',').map do |x|
      x.split(':').last.delete('+')
    end.join(',')
  end

  def facets
    if @type == 'books'
      ENV['EDS_BOOK_FACETS']
    else
      ENV['EDS_ARTICLE_FACETS']
    end
  end

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
