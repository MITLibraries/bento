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
      @record['pnx']['display']['creator'].each do |au|
        author = sanitize_author(au)
        author_list << [author, author_link(author)]
      end
    end

    if @record['pnx']['display']['contributor']
      @record['pnx']['display']['contributor'].each do |au|
        author = sanitize_author(au)
        author_list << [author, author_link(author)]
      end
    end

    author_list.uniq
  end

  # This method is required to remove MARC artifacts from the API response
  def sanitize_author(author)
    author.gsub(/\$\$Q.*$/, '')
  end

  def author_link(author)
    [ENV['MIT_PRIMO_URL'], '/discovery/search?query=creator,exact,', 
     author, '&vid=', ENV['PRIMO_VID']].join('')
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
    }
    r_types[type] || type.capitalize
  end
end
