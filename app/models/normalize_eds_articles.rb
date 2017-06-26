# Tranforms results from {SearchEds} into normalized {Result}s
# for metadata that is relevant for article type results
class NormalizeEdsArticles
  def initialize(record)
    @record = record
  end

  def article_metadata(result)
    result.citation = numbering
    result.in = journal_title
    result.get_it_label = 'Get it'
    result.openurl = construct_open_url(result)
    result
  end

  def construct_open_url(result)
    'https://sfx.mit.edu/sfx_local?' +
      openurl(
        result.year, result.authors&.map(&:first)
      )
  end

  def openurl(year, authors)
    # build a hash of params we care about then run to_query on it
    {
      'rft.au' => authors&.join(';'),
      'rft_id' => "info:doi/#{doi}",
      'rft.jtitle' => journal_title,
      'rft.volume' => volume_issue('volume'),
      'rft.issue' => volume_issue('issue'), 'rft.year' => year,
      'rft.eissn' => identifier('issn-electronic'),
      'rft.issn' => identifier('issn-print'),
      'rfr_id' => 'info:sid/MIT.BENTO'
    }.to_query
  end

  def doi
    return unless bibrecord['BibEntity']['Identifiers']
    doi_selector = bibrecord['BibEntity']['Identifiers'].select do |i|
      i['Type'] == 'doi'
    end
    doi_selector&.first['Value']
  end

  def journal_title
    return unless bibentity && bibentity['Titles']
    bibentity['Titles'][0]['TitleFull']
  end

  def identifier(type)
    return unless identifiers
    identifiers.map { |id| id[type] }.first
  end

  def identifiers
    return unless bibentity && bibentity['Identifiers']
    bibentity['Identifiers'].map do |x|
      { x['Type'] => x['Value'] }
    end
  end

  def numbering
    return unless bibentity
    numbers = bibentity['Numbering']&.map do |x|
      "#{x['Type']} #{x['Value']}"
    end
    numbers&.join(' ')
  end

  def volume_issue(type)
    return unless bibentity
    volume_issue = bibentity['Numbering']&.select do |i|
      i['Type'] == type
    end
    volume_issue.first['Value'] if volume_issue.present?
  end

  def bibrecord
    @record.dig('RecordInfo', 'BibRecord')
  end

  def bibentity
    return unless relationships['IsPartOfRelationships']
    relationships['IsPartOfRelationships'][0]['BibEntity']
  end

  def relationships
    bibrecord['BibRelationships']
  end
end
