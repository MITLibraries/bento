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
    result.custom_link = custom_link
    result.marc_856 = marc_856
    result
  end

  def custom_link
    @record.dig('FullText', 'CustomLinks')
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
    title
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
    @record['RecordInfo']['BibRecord']['BibEntity']['Titles']
  end

  def year
    return unless bibentity['Dates']
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
      [author_name(author_node), author_link(author_node)]
    end
  end

  def author_name(author_node)
    author_node.dig('PersonEntity', 'Name', 'NameFull')
  end

  def author_link(author_node)
    ENV['EDS_PROFILE_URI'] + author_search_format(author_node)
  end

  def author_search_format(author_node)
    URI.encode_www_form_component("AU \"#{author_name(author_node)}\"")
  end

  def db_source
    [@record.dig('Header', 'DbLabel'), @record.dig('Header', 'DbId')]
  end

  def contributors
    relationships['HasContributorRelationships']
  end

  def bibentity
    relationships['IsPartOfRelationships'][0]['BibEntity']
  end

  def relationships
    @record.dig('RecordInfo', 'BibRecord', 'BibRelationships')
  end
end
