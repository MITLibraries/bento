# Tranforms results from {SearchTimdex} into normalized {Result}s
#
class NormalizeTimdex
  # Translate Timdex results into local result model
  def to_result(results, q)
    norm = {}
    norm['total'] = results['data']['search']['hits']
    norm['results'] = []
    norm['view_more'] = view_more(q)
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
      result.year = extract_dates(record['dates'])
      result.authors = extract_field(extract_list(record['contributors']))
      result.physical_description = extract_field(record['physicalDescription'])
      norm['results'] << result
    end
  end

  def extract_title(record)
    title = record['title']
    title << extract_collection_id(record['identifiers']) if record['identifiers'].present?
    title
  end

  def extract_dates(dates)
    return unless dates

    # It is unlikely for a record to have more than one creation or publication date, but just in case...
    relevant_dates = dates.select { |date| date['kind'] == 'creation' || date['kind'] == 'publication' }

    # If the record has no creation or publication date, stop here.
    return if relevant_dates.empty?

    # If the record *does* have more than one creation/pub date, just take the first one.
    relevant_date = relevant_dates.first

    # We are only concerned with creation/pub dates that are ranges, since we harvest ASpace metadata at the collection
    # level.
    return unless relevant_date['range'].present?

    "#{relevant_date['range']['gte']}-#{relevant_date['range']['lte']}"
  end

  def extract_collection_id(identifiers)
    relevant_ids = identifiers.map { |id| id['value'] if id['kind'] == 'Collection Identifier' }.compact

    # In the highly unlikely event that there is more than one collection identifier, there's something weird going
    # on with the record and we should skip it.
    return if relevant_ids.count > 1

    " (#{relevant_ids.first})"
  end

  def extract_list(contributors)
    contributors&.map do |creator|
      [creator['value'], '&field[]=creators_text&q[]=' << URI.encode_www_form_component(creator['value'])]
    end
  end

  def extract_field(value)
    value.present? ? value : false
  end

  def extract_first_from_list(list)
    list.present? ? list[0] : false
  end
end
