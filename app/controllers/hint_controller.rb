class HintController < ApplicationController
  def hint
    return if params[:q].blank?
    @hint = Hint.match(params[:q])
    if (@hint && ENV['GOOGLE_ANALYTICS'])
      tracker = Staccato.tracker(ENV['GOOGLE_ANALYTICS'], nil, ssl: true)
      tracker.event(category: 'Bento', action: 'Hint', label: 'Show', value: 1)
    end
    render layout: false
  end
end
