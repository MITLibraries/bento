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
      result.authors = authors(record)
      norm['results'] << result
    end
  end

  def result(record)
    result = Result.new(title(record), link(record))
    result.year = year(record)
    result.type = type(record)
    result.online = availability(record)
    result = article_stuff(record, result) unless @type == 'books'
    result = book_stuff(record, result) if @type == 'books'
    result
  end

  def article_stuff(record, result)
    result.citation = NormalizeEdsArticles.new(record).numbering(record)
    result.in = NormalizeEdsArticles.new(record).journal_title(record)
    result
  end

  def book_stuff(record, result)
    result.thumbnail = NormalizeEdsBooks.new(record).thumbnail(record)
    result.publisher = NormalizeEdsBooks.new(record).publisher(record)
    result.location = NormalizeEdsBooks.new(record).location(record)
    result.subjects = NormalizeEdsBooks.new(record).subjects(record)
    result
  end

  def title(record)
    bib = record['RecordInfo']['BibRecord']['BibEntity']
    bib['Titles'][0]['TitleFull']
  rescue
    'unknown title'
  end

  def year(record)
    return unless bibentity(record)['Dates']
    bibentity(record)['Dates'][0]['Y']
  end

  def link(record)
    if @type == 'books'
      record['PLink']
    elsif sfx_link(record)&.select { |l| l.include?('sfx.mit') }.present?
      URI.escape(sfx_link(record)&.select { |l| l.include?('sfx.mit') }.first +
      '&rfr_id=info:sid/MIT.BENTO')
    else
      construct_open_url(record)
    end
  end

  def construct_open_url(record)
    'https://sfx.mit.edu/sfx_local?' +
      NormalizeEdsArticles.new(record).openurl(
        record, year(record), authors(record)&.map(&:first)
      )
  end

  def availability(record)
    record['FullText']['Text']['Availability']&.to_i
  end

  def sfx_link(record)
    record['FullText']['CustomLinks']&.map { |l| l['Url'] }
  end

  def type(record)
    record.dig('Header', 'PubType')
  end

  def authors(record)
    contributors(record)&.map do |author_node|
      [author_name(author_node), author_link(author_node)]
    end
  end

  def author_name(author_node)
    author_node.dig('PersonEntity', 'Name', 'NameFull')
  end

  def author_link(author_node)
    if @type == 'books'
      ENV['EDS_ALEPH_URI'] + author_search_format(author_node)
    else
      ENV['EDS_NO_ALEPH_URI'] + author_search_format(author_node)
    end
  end

  def author_search_format(author_node)
    URI.encode_www_form_component("AU \"#{author_name(author_node)}\"")
  end

  def contributors(record)
    relationships(record)['HasContributorRelationships']
  end

  def bibentity(record)
    relationships(record)['IsPartOfRelationships'][0]['BibEntity']
  end

  def relationships(record)
    record.dig('RecordInfo', 'BibRecord', 'BibRelationships')
  end
end
