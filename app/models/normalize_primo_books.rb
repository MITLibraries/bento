# Tranforms results from {SearchPrimo} into normalized {Result}s
# for metadata that is relevant for book type results
class NormalizePrimoBooks
  def initialize(record)
    @record = record
  end

  def book_metadata(result)
    result.thumbnail = thumbnail
    result.publisher = publisher
    result.location = location
    result.subjects = subjects
    result
  end

  def thumbnail
    return unless @record['pnx']['addata']['isbn']

    # A record can have multiple ISBNs, so we are assuming here that 
    # the thumbnail URL can be constructed from the first occurrence
    isbn = @record['pnx']['addata']['isbn'].first
    [ENV['SYNDETICS_PRIMO_URL'], '&isbn=', isbn, '/sc.jpg'].join('')
  end

  def publisher
    return unless @record['pnx']['display']['publisher']
    @record['pnx']['display']['publisher'].join('')
  end

  def subjects
    return unless @record['pnx']['display']['subject']
    @record['pnx']['display']['subject'].map do |subj|
      [subj, subject_link(subj)]
    end
  end

  def subject_link(subj)
    [ENV['MIT_PRIMO_URL'], '/discovery/search?query=sub,exact,', 
     subj, '&vid=', ENV['PRIMO_VID']].join('')
  end

  def location
    return unless @record['delivery']['holding'] && @record['delivery']['bestlocation']
    return if @record['delivery']['bestlocation']['mainLocation'] == 'Internet Resource'
    location_concatted = @record['delivery']['bestlocation']['mainLocation'] + ' ' + @record['delivery']['bestlocation']['subLocation']
    call_number = @record['delivery']['bestlocation']['callNumber']
    [[location_concatted, call_number]]
  end
end
