class RecordController < ApplicationController
  rescue_from EBSCO::EDS::BadRequest, with: proc {
    raise ActionController::RoutingError, 'Record not found'
  }

  def record
    return redirect_to root_url unless valid_url?

    fetch_eds_record

    # Don't use q as the parameter here - that will cause the search form to
    # notice the parameter and prefill the search, which is behavior we *don't*
    # want.
    @previous = params[:previous]
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
end
