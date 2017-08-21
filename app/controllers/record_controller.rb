class RecordController < ApplicationController
  def record
    record_source = params[:db_source]
    record_an = params[:an]
    return redirect_to root_url unless record_source && record_an
    session = EBSCO::EDS::Session.new({:user=>ENV['EDS_USER_ID'],
                                       :pass=>ENV['EDS_PASSWORD'],
                                       :profile=>ENV['EDS_PROFILE']})
    @record = session.retrieve({dbid: record_source, an: record_an})
    render 'record'
  end
end