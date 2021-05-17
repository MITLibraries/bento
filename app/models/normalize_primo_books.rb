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
    result.openurl = openurl
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
    [ENV['MIT_PRIMO_URL'], '/discovery/browse?browseQuery=', 
     subj, '&browseScope=subject.1&vid=', ENV['PRIMO_VID']].join('')
  end

  def location
    return unless @record['delivery']['holding'] && @record['delivery']['bestlocation']
    return if @record['delivery']['bestlocation']['mainLocation'] == 'Internet Resource'
    @record['delivery']['holding'].map do |holding|
      return unless holding['mainLocation'] && holding['subLocation'] && holding['callNumber']
      ["#{holding['mainLocation']} #{holding['subLocation']}", holding['callNumber']]
    end
  end

  def openurl
    return unless @record['pnx']['display']['mms']
    return unless @record['delivery']['deliveryCategory']
    mms_id = @record['pnx']['display']['mms'].first
    if @record['delivery']['deliveryCategory'].include?('Alma-E')
      [ENV['MIT_PRIMO_URL'], '/discovery/openurl?institution=', 
       ENV['EXL_INST_ID'], '&vid=', ENV['PRIMO_VID'], '&rft.mms_id=', mms_id,
       '&u.ignore_date_coverage=true'].join('')
    end
  end
end
