class HintController < ApplicationController
  def hint
    return if params[:q].blank?

    @hint = Hint.match(params[:q])
    render layout: false
  end
end
