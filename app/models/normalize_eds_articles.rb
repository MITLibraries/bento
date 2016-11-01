# Tranforms results from {SearchEds} into normalized {Result}s
#
class NormalizeEdsArticles
  def initialize(record)
    @record = record
  end

  def openurl(record, year, authors)
    # build a hash of params we care about then run to_query on it
    {
      'rft.au' => authors&.join(';'),
      'rft_id' => "info:doi/#{doi(record)}",
      'rft.jtitle' => journal_title(record),
      'rft.volume' => volume(record),
      'rft.issue' => issue(record),
      'rft.year' => year,
      'rfr_id' => 'info:sid/MIT.BENTO'
    }.to_query
  end

  def doi(record)
    return unless bibrecord(record)['BibEntity']['Identifiers']
    doi_selector = bibrecord(record)['BibEntity']['Identifiers'].select do |i|
      i['Type'] == 'doi'
    end
    doi_selector&.first['Value']
  end

  def journal_title(record)
    bibentity(record)['Titles'][0]['TitleFull'] if bibentity(record)['Titles']
  end

  def numbering(record)
    numbers = bibentity(record)['Numbering']&.map do |x|
      "#{x['Type']} #{x['Value']}"
    end
    numbers&.join(' ')
  end

  def volume(record)
    volume = bibentity(record)['Numbering']&.select do |i|
      i['Type'] == 'volume'
    end
    volume.first['Value'] if volume.present?
  end

  def issue(record)
    issue = bibentity(record)['Numbering']&.select do |i|
      i['Type'] == 'issue'
    end
    issue.first['Value'] if issue.present?
  end

  def bibrecord(record)
    record.dig('RecordInfo', 'BibRecord')
  end

  def bibentity(record)
    relationships(record)['IsPartOfRelationships'][0]['BibEntity']
  end

  def relationships(record)
    bibrecord(record)['BibRelationships']
  end
end
