# Tranforms results from {SearchPrimo} into normalized {Result}s
# for metadata that is relevant for book type results
class NormalizePrimoBooks
  def initialize(record, query)
    @record = record
    @query = query
  end

  def book_metadata(result)
    result.thumbnail = thumbnail
    result.publisher = publisher
    result.location = best_location
    result.subjects = subjects
    result.openurl = openurl
    result.availability = best_availability
    result.other_availability = other_availability?
    result.dedup_url = dedup_url
    result
  end

  def thumbnail
    return unless @record['pnx']['addata']['isbn']

    # A record can have multiple ISBNs, so we are assuming here that
    # the thumbnail URL can be constructed from the first occurrence
    isbn = @record['pnx']['addata']['isbn'].first
    [ENV['SYNDETICS_PRIMO_URL'], '&isbn=', isbn, '/sc.jpg'].join
  end

  def publisher
    return unless @record['pnx']['display']['publisher']

    @record['pnx']['display']['publisher'].join
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
     ENV['PRIMO_VID']].join
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
       '&u.ignore_date_coverage=true'].join
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

  # FRBR type '5' means the record is frbrized. and '6' means it isn't:
  # https://knowledge.exlibrisgroup.com/Primo/Knowledge_Articles/Primo_Search_API_-_how_to_get_FRBR_Group_members_after_a_search
  def frbrized?
    return unless @record['pnx']['facets']
    return unless @record['pnx']['facets']['frbrtype']

    @record['pnx']['facets']['frbrtype'].join == '5'
  end

  def dedup_url
    return unless frbrized?
    return unless @record['pnx']['facets']['frbrgroupid'] && @record['pnx']['facets']['frbrgroupid'].length == 1

    frbr_group_id = @record['pnx']['facets']['frbrgroupid'].join
    base = [ENV['MIT_PRIMO_URL'], '/discovery/search?'].join
    query = {
      query: "any,contains,#{@query}",
      tab: ENV['PRIMO_TAB'],
      search_scope: ENV['PRIMO_BOOK_SCOPE'],
      sortby: 'date_d',
      vid: ENV['PRIMO_VID'],
      facet: "frbrgroupid,include,#{frbr_group_id}"
    }.to_query
    [base, query].join
  end
end
