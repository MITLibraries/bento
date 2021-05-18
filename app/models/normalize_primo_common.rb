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
      title = @record['pnx']['display']['title'].join('')
    else
      title = 'unknown title'
    end
    title
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
    if authors.any? { |author| author.include?(';') }
      authors.map! { |author| author.split(';') }.flatten!
    end

    authors.map { |author| author.strip.gsub(/\$\$Q.*$/, '') }
  end

  def author_link(author)
    [ENV['MIT_PRIMO_URL'], '/discovery/browse?browseQuery=', 
     author, '&browseScope=author&vid=', ENV['PRIMO_VID']].join('')
  end

  def year
    if @record['pnx']['display']['creationdate'].present?
      @record['pnx']['display']['creationdate'].join('')
    else
      return unless @record['pnx']['search'] && @record['pnx']['search']['creationdate']
      @record['pnx']['search']['creationdate'].join('')
    end
  end

  def link
    return unless @record['pnx']['control']['recordid']
    record_id = @record['pnx']['control']['recordid'].join('')
    [ENV['MIT_PRIMO_URL'], '/discovery/fulldisplay?docid=', record_id, 
     '&vid=', ENV['PRIMO_VID']].join('')
  end

  def type
    return unless @record['pnx']['display']['type']
    normalize_type(@record['pnx']['display']['type'].join(''))
  end

  def recordid
    return unless @record['pnx']['control']['recordid']
    @record['pnx']['control']['recordid'].join('')
  end

  def normalize_type(type)
    r_types = {
      "BKSE" => "eBook",
      "reference_entry" => "Reference Entry",
      "Book_chapter" => "Book Chapter"
    }
    r_types[type] || type.capitalize
  end
end
