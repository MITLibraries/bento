class RecordController < ApplicationController
  before_action :restricted!, only: [:direct_link]
  before_action :valid_url!

  rescue_from EBSCO::EDS::BadRequest, with: proc {
    raise RecordController::NoSuchRecordError, 'Record not found'
  }

  class NoSuchRecordError < StandardError; end

  include Rainbows

  def record
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

  def direct_link
    fetch_eds_record
    redirect_to @record.fulltext_link[:url]
  end

  private

  def valid_url!
    return redirect_to root_url unless valid_url?
  end

  def restricted!
    return unless helpers.guest?
    flash[:error] = 'Restricted access. Please use our feedback form for ' \
                    'assistance.'
    redirect_to root_url
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
                                      guest: helpers.guest?,
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
