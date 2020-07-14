class RecordController < ApplicationController
  before_action :restricted!, only: [:direct_link]
  before_action :valid_url!

  class NoSuchRecordError < StandardError; end
  class DbLimitReached < StandardError; end
  class UnknownEdsError < StandardError; end

  rescue_from NoSuchRecordError, with: :no_such_record

  def no_such_record
    render 'not_found', status: 404
  end

  # We are using ActionCaching due to EDS not providing an readily cacheable
  # object to use with low level caching like we do with our bento results.
  # They provide a cache option but it is hardcoded to use a file system cache.
  # I have asked for that to be revisited upstream. Fragment Caching is an
  # option but in initial exploration this honestly seems easier.
  caches_action :record, expires_in: 1.day, cache_path: :cache_path

  include Rainbows

  # See https://github.com/ebsco/edsapi-ruby/ . The page which gives all the
  # affordances of the record object is lib/ebsco/eds/record.rb.
  def record
    with_session_error_handling { fetch_eds_record }
    if @record
      @keywords = extract_eds_text(@record.eds_author_supplied_keywords)
      @subjects = extract_eds_text(@record.eds_subjects)

      # Don't use q as the parameter here - that will cause the search form to
      # notice the parameter and prefill the search, which is behavior we *don't*
      # want.
      @previous = params[:previous]
      rainbowify? if Flipflop.enabled?(:pride)
      render 'record'
    else
      render 'errors/eds_session_error'
    end
  end

  # this method should never be cached because we need a fresh expiring URL
  def direct_link
    fetch_eds_record
    redirect_to @record.fulltext_link[:url]
  end

  protected

  # This is effectively a cache key based on the parameters we care about.
  # record cache is guest dependent because it stores rendered HTML, and some
  # of that rendered HTML is different for guests.
  def cache_path
    url_for(
      guest: helpers.guest?,
      action: action_name,
      an: @record_an,
      source: @record_source,
      pride: Flipflop.enabled?(:pride)
    )
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
                                      use_cache: false,
                                      debug: ENV['EDS_DEBUG'])
    @record = with_error_handling do
      session.retrieve(dbid: @record_source, an: @record_an)
    end
  end

  def with_session_error_handling
    yield
  rescue NoMethodError => e
    Rails.logger.warn("EDS Error Detected while retrieving full record: #{e}")
    @eds_error_link = rebuild_eds_full_record_link
  end

  # detect and log known and unknown eds failures separately so we can
  # better understand what is happening
  def with_error_handling
    yield
  rescue EBSCO::EDS::BadRequest => e
    if e.message.include?('Simultaneous User Limit Reached')
      raise RecordController::DbLimitReached, e
    elsif e.message.include?('DbId Not In Profile')
      raise RecordController::NoSuchRecordError
    elsif e.message.include?('Record not found')
      raise RecordController::NoSuchRecordError
    else
      raise RecordController::UnknownEdsError, e
    end
  end

  # rebuild a EDS UI Full Record Link if our local is broken
  def rebuild_eds_full_record_link
    db, an = request.fullpath.split('/').reject(&:blank?) - ['record']
    ['http://search.ebscohost.com/login.aspx?direct=true&site=eds-live',
     "&db=#{db}",
     "&AN=#{an}",
     '&custid=s8978330&groupid=main&profile=eds&authtype=ip,sso'].join
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
