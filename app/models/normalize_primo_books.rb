# Tranforms results from {SearchPrimo} into normalized {Result}s
# for metadata that is relevant for book type results
class NormalizePrimoBooks
  def initialize(record)
    @record = record
  end

  def book_metadata(result)
    result.thumbnail = thumbnail
    result.publisher = publisher
    result.location = best_location
    result.subjects = subjects
    result.openurl = openurl
    result.availability = best_availability
    result.other_availability = other_availability?
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
    # We need to remove hyphens to accommodate Primo's subject browse
    subj = subj.split('--').map { |el| el.strip }.join(' ') if subj.include?('--')
    [ENV['MIT_PRIMO_URL'], '/discovery/search?query=subject,exact,', 
     subj, '&tab=', ENV['PRIMO_MAIN_VIEW_TAB'], '&search_scope=all&vid=', 
     ENV['PRIMO_VID']].join('')
  end

  # Since we are displaying RTA based on the best location, this is the 
  # only location data we need
  def best_location
    return unless @record['delivery']['bestlocation']
    return if @record['delivery']['bestlocation']['mainLocation'] == 'Internet Resource'
    loc = @record['delivery']['bestlocation']
    ["#{loc['mainLocation']} #{loc['subLocation']}", loc['callNumber']]
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

  def best_availability
    return unless best_location
    @record['delivery']['bestlocation']['availabilityStatus']
  end

  def other_availability?
    return unless @record['delivery']['bestlocation']
    return unless @record['delivery']['holding']
    @record['delivery']['holding'].any? do |holding|
      next if holding == @record['delivery']['bestlocation']
      holding['availabilityStatus'] == 'available'
    end
  end
end
