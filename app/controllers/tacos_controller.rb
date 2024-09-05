class TacosController < ApplicationController
  # Calls TACOS API to log search terms and return suggested resources.
  def suggested_resources
    # Do nothing unless all required env is set and a query param exists.
    return if ENV.fetch('TACOS_URL', nil).blank? || ENV.fetch('ORIGINS', nil).blank?
    return if params[:q].blank?

    response = Tacos.call(params[:q])
    @suggested_resources = response['data']['logSearchEvent']['detectors']['suggestedResources']
    render layout: false
  end
end
