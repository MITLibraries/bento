class TacosController < ApplicationController
  # Calls TACOS API to log search terms and return suggested resources. 
  def suggested_resources
    return if params[:q].blank?

    @response = Tacos.call(params[:q])
    render layout: false
  end
end
