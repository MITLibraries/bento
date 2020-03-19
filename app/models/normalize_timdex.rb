# Tranforms results from {SearchTimdex} into normalized {Result}s
#
class NormalizeTimdex
  # Translate Timdex results into local result model
  def to_result(results, q)
    norm = {}
    norm['total'] = results['data']['search']['hits']
    norm['results'] = []
    norm['eds_ui_view_more'] = view_more(q)
    extract_results(results, norm)
    norm
  end

  private

  def view_more(q)
    "https://archivesspace.mit.edu/search?op%5B%5D=&q%5B%5D=#{q}"
  end

  def extract_results(results, norm)
    return unless results['data']['search']['records']
    results['data']['search']['records'].first(5).each do |record|
      result_title = extract_title(record)
      result = Result.new(result_title, record['sourceLink'])
      result.blurb = extract_first_from_list(record['summary'])
      result.year = extract_field(record['publicationDate'])
      result.authors = extract_field(extract_list(record['contributors']))
      result.physical_description = extract_field(record['physicalDescription'])
      norm['results'] << result
    end
  end

  def extract_title(record)
    title = record['title']
    if record['identifier'].present?
      title << ' (' + record['identifier'].to_s.gsub('MIT:archivespace:','') + ')'
    end
    return title
  end

  def extract_list(contributors)
    contributors&.map do |creator|
      [creator['value'], "&field[]=creators_text&q[]=" << URI.encode_www_form_component(creator['value'])]
    end
  end

  def extract_field(value)
    ( value.present? ) ? value : false
  end

  def extract_first_from_list(list)
    ( list.present? ) ? list[0] : false
  end
end
