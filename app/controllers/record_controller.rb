class RecordController < ApplicationController
  rescue_from EBSCO::EDS::BadRequest, with: proc {
    raise ActionController::RoutingError, 'Record not found'
  }

  def record
    return redirect_to root_url unless valid_url?

    fetch_eds_record
    use_sfx?

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

  # If the top EDS fulltext link is an SFX link, we want to present an
  # unstyled link to check for fulltext online. Otherwise we want an
  # attention-getting 'view online' button
  def use_sfx?
    url = @record.fulltext_link[:url]
    # SFX URLs observed in the wild: owens.mit.edu/sfx_local,
    # sfx.mit.edu/sfx_local, library.mit.edu/?func=service-sfx
    @use_sfx = url.present? && (
      url.match?('mit.edu/sfx') || url.match?('func=service-sfx'))
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
