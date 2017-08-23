class RecordController < ApplicationController
  rescue_from EBSCO::EDS::BadRequest, with: Proc.new{ raise ActionController::RoutingError.new('Record not found') }

  def record
    record_source = params[:db_source]
    record_an = params[:an]
    return redirect_to root_url unless record_source && record_an
    session = EBSCO::EDS::Session.new({:user=>ENV['EDS_USER_ID'],
                                       :pass=>ENV['EDS_PASSWORD'],
                                       :profile=>ENV['EDS_PROFILE']})
    @record = session.retrieve({dbid: record_source, an: record_an})
    # Don't use q as the parameter here - that will cause the search form to
    # notice the parameter and prefill the search, which is behavior we *don't*
    # want.
    @previous = params[:previous]
    render 'record'
  end
end