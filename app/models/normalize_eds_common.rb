# Tranforms results from {SearchEds} into normalized {Result}s
# for metadata that is common across all result types
class NormalizeEdsCommon
  def initialize(record, type)
    @record = record
    @type = type
  end

  def common_metadata(result)
    result.authors = authors
    result.year = year
    result.type = type
    result.online = availability
    result.db_source = db_source
    result.an = @record.dig('Header', 'An')
    links(result)
    result.uniform_title = uniform_title
    result
  end

  # consolidate various link related construction here
  def links(result)
    result.fulltext_links = fulltext_links
    result.record_links = record_links
    result.marc_856 = marc_856
  end

  def fulltext_links
    @record.dig('FullText', 'CustomLinks')
  end

  def record_links
    @record.dig('CustomLinks')
  end

  def marc_856
    return unless extract_by_name('URL')
    double_split(extract_by_name('URL'), 'linkTerm=', 'linkWindow=')
  end

  # This extracts the url from the string format eds supplies
  def double_split(string, leadterm, endterm)
    string.split(leadterm).last.split(endterm).first.gsub('&quot;', '').strip
  end

  def title
    title = extract_by_name('Title') if extract_by_name('Title')
    title = title_full.first if title_full
    title = 'unknown title' unless title
    Nokogiri::HTML.fragment(title).to_s
  end

  def title_full
    titles.try(:map) { |x| x['TitleFull'] }
  end

  def extract_by_name(name)
    return unless @record['Items'].try(:select) { |x| x['Name'] == name }
    @record['Items'].try(:select) { |x| x['Name'] == name }.map do |x|
      x['Data']
    end.first
  end

  def titles
    @record.dig('RecordInfo', 'BibRecord', 'BibEntity', 'Titles')
  end

  def uniform_title
    return unless extract_by_name('TitleAlt')
    return if extract_by_name('TitleAlt').include?('searchLink fieldCode')
    Nokogiri::HTML.fragment(extract_by_name('TitleAlt')).to_s
  end

  def year
    return unless bibentity && bibentity['Dates']
    bibentity['Dates'][0]['Y']
  end

  def link
    "#{@record['PLink'].gsub('&authtype=sso', '')}#{ENV['EDS_PLINK_APPEND']}"
  end

  def availability
    @record['FullText']['Text']['Availability']&.to_i
  end

  def type
    @record.dig('Header', 'PubType')
  end

  def authors
    contributors&.map do |author_node|
      [author_name(author_node), author_search_format(author_node)]
    end
  end

  def author_name(author_node)
    author_node.dig('PersonEntity', 'Name', 'NameFull')
  end

  def author_search_format(author_node)
    URI.encode_www_form_component("AU \"#{author_name(author_node)}\"")
  end

  def db_source
    [@record.dig('Header', 'DbLabel'), @record.dig('Header', 'DbId')]
  end

  def contributors
    return unless relationships
    relationships['HasContributorRelationships']
  end

  def bibentity
    return unless relationships
    return unless relationships['IsPartOfRelationships']
    relationships['IsPartOfRelationships'][0]['BibEntity']
  end

  def relationships
    @record.dig('RecordInfo', 'BibRecord', 'BibRelationships')
  end
end
