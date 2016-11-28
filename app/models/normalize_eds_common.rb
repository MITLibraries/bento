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
    result
  end

  def title
    title = title_item if title_item
    title = title_full.first if title_full
    title = 'unknown title' unless title
    title
  end

  def title_full
    titles.try(:map) { |x| x['TitleFull'] }
  end

  def title_item
    @record['Items'].try(:select) { |x| x['Name'] == 'Title' }.map do |x|
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
    @record['PLink']
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
    if @type == 'books'
      ENV['EDS_ALEPH_URI'] + author_search_format(author_node)
    else
      ENV['EDS_NO_ALEPH_URI'] + author_search_format(author_node)
    end
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
