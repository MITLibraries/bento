class RecordController < ApplicationController
  # We need to leave this method and the direct_link route because the record links have historically been used as
  # permalinks and should therefore be redirected to Primo records indefinitely.
  def record
    primo_redirect
    nil
  end

  private

  def alma_sru
    return unless params[:an]
    return unless params[:an].start_with?('mit')

    alma_system_id = params[:an].split('.').last.concat('MIT01')
    url = ENV.fetch('ALMA_SRU') + alma_system_id
    response = HTTP.get(url)
    Nokogiri::XML.parse(response)
  end

  def alma_docid
    return if alma_sru.blank?

    records = alma_sru.xpath('//srw:searchRetrieveResponse/srw:records/srw:record', 'srw' => 'http://www.loc.gov/zing/srw/')

    # We should attempt a redirect iff there is one record
    return unless records.length == 1

    records.xpath('//srw:recordIdentifier', 'srw' => 'http://www.loc.gov/zing/srw/').text.prepend('alma')
  end

  def primo_redirect
    redirect_url = if alma_docid.present?
                     [ENV.fetch('MIT_PRIMO_URL'), '/discovery/fulldisplay?docid=',
                      alma_docid, '&vid=', ENV.fetch('PRIMO_VID')].join
                   else
                     ENV.fetch('PRIMO_SPLASH_PAGE')
                   end
    redirect_to redirect_url, status: 308
  end
end
