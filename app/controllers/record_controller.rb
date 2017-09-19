class RecordController < ApplicationController
  rescue_from EBSCO::EDS::BadRequest, with: proc {
    raise ActionController::RoutingError, 'Record not found'
  }

  include Rainbows

  def record
    return redirect_to root_url unless valid_url?

    fetch_eds_record
    @keywords = extract_eds_text(@record.eds_author_supplied_keywords)
    @subjects = extract_eds_text(@record.eds_subjects)

    # Don't use q as the parameter here - that will cause the search form to
    # notice the parameter and prefill the search, which is behavior we *don't*
    # want.
    @previous = params[:previous]
    rainbowify? if Flipflop.enabled?(:pride)
    render 'record'
  end

  def valid_url?
    @record_source = params[:db_source]
    @record_an = params[:an]
    @record_source.present? && @record_an.present?
  end

  def fetch_eds_record
    session = EBSCO::EDS::Session.new(user: ENV['EDS_USER_ID'],
                                      pass: ENV['EDS_PASSWORD'],
                                      profile: ENV['EDS_PROFILE'],
                                      guest: false, # this will be dynamic soon
                                      org: 'mit',
                                      use_cache: false)
    @record = session.retrieve(dbid: @record_source, an: @record_an)
  end

  # Keywords and subjects are sometimes provided as lists and sometimes as
  # provided as chunks of HTML suitable for rendering EDS links, but we need
  # them as simple lists of items.
  def extract_eds_text(stuff)
    return if stuff.blank?
    return stuff if stuff.is_a? Array
    parsed_html = Nokogiri::HTML.fragment(CGI.unescapeHTML(stuff))
    parsed_html.search('searchlink').map(&:text).map(&:strip)
  end
end
