# Tranforms results from {SearchPrimo} into normalized {Result}s
# for metadata that is common across all result types
class NormalizePrimoCommon
  def initialize(record, type)
    @record = record
    @type = type
  end

  def common_metadata(result)
    result.title = title
    result.authors = authors
    result.year = year
    result.type = type
    result.an = recordid
    result
  end

  def title
    if @record['pnx']['display']['title'].present?
      @record['pnx']['display']['title'].join
    else
      'unknown title'
    end
  end

  def authors
    return unless @record['pnx']['display']['creator'] || @record['pnx']['display']['contributor']

    author_list = []

    if @record['pnx']['display']['creator']
      creators = sanitize_authors(@record['pnx']['display']['creator'])
      creators.each do |creator|
        author_list << [creator, author_link(creator)]
      end
    end

    if @record['pnx']['display']['contributor']
      contributors = sanitize_authors(@record['pnx']['display']['contributor'])
      contributors.each do |contributor|
        author_list << [contributor, author_link(contributor)]
      end
    end

    author_list.uniq
  end

  # This method is required to clean up bad data in the API response
  def sanitize_authors(authors)
    authors.map! { |author| author.split(';') }.flatten! if authors.any? { |author| author.include?(';') }

    authors.map { |author| author.strip.gsub(/\$\$Q.*$/, '') }
  end

  def author_link(author)
    [ENV.fetch('MIT_PRIMO_URL', nil), '/discovery/search?query=creator,exact,',
     clean_author(author), '&tab=', ENV.fetch('PRIMO_MAIN_VIEW_TAB', nil), '&search_scope=all&vid=',
     ENV.fetch('PRIMO_VID', nil)].join
  end

  def clean_author(author)
    URI.encode_uri_component(author)
  end

  def year
    if @record['pnx']['display']['creationdate'].present?
      @record['pnx']['display']['creationdate'].join
    else
      return unless @record['pnx']['search'] && @record['pnx']['search']['creationdate']

      @record['pnx']['search']['creationdate'].join
    end
  end

  # We've altered this method slightly to address bugs introduced in the Primo VE November 2021 release. The search_scope
  # param is now required for CDI fulldisplay links, and the context param is now required for local (catalog)
  # fulldisplay links.
  #
  # In order to avoid more surprises, we're adding all of the params included in the fulldisplay exmaple links provided
  # here, even though not all of them are actually required at present:
  # https://developers.exlibrisgroup.com/primo/apis/deep-links-new-ui/
  #
  # We should keep an eye on this over subsequent Primo reeleases and revert it to something more minimalist/sensible
  # when Ex Libris fixes this issue.
  def link
    return unless @record['pnx']['control']['recordid']
    return unless @record['context']

    record_id = @record['pnx']['control']['recordid'].join
    base = [ENV.fetch('MIT_PRIMO_URL'), '/discovery/fulldisplay?'].join
    query = {
      docid: record_id,
      vid: ENV.fetch('PRIMO_VID'),
      context: @record['context'],
      search_scope: 'all',
      lang: 'en',
      tab: ENV.fetch('PRIMO_MAIN_VIEW_TAB')
    }.to_query
    [base, query].join
  end

  def type
    return unless @record['pnx']['display']['type']

    normalize_type(@record['pnx']['display']['type'].join)
  end

  def recordid
    return unless @record['pnx']['control']['recordid']

    @record['pnx']['control']['recordid'].join
  end

  def normalize_type(type)
    r_types = {
      'BKSE' => 'eBook',
      'reference_entry' => 'Reference Entry',
      'Book_chapter' => 'Book Chapter'
    }
    r_types[type] || type.capitalize
  end
end
