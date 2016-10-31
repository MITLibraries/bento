# Tranforms results from {SearchEds} into normalized {Result}s
#
class NormalizeEds
  # Translate EDS results into local result model
  def to_result(results)
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
    result
  end

  def title(record)
    bibentity = record['RecordInfo']['BibRecord']['BibEntity']
    bibentity['Titles'].first['TitleFull']
  end

  def year(record)
    return unless bibentity(record)['Dates']
    bibentity(record)['Dates'][0]['Y']
  end

  def link(record)
    record['PLink']
  end

  def type(record)
    record.dig('Header', 'PubType')
  end

  def authors(record)
    contributors(record)&.map { |r| r.dig('PersonEntity', 'Name', 'NameFull') }
  end

  def contributors(record)
    relationships(record)['HasContributorRelationships']
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
