class HintController < ApplicationController
  def hint
    return unless params[:q].present?
    @hint = Hint.match(params[:q])
    render layout: false
  end
end
