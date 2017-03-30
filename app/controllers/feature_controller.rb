class FeatureController < ApplicationController
  before_action :validate_feature!

  # Toggles boolean for session based feature flags
  def toggle
    session[legit_feature] = session[legit_feature].!
    flash[:info] = success_message
    redirect_to root_path
  end

  private

  # message to display on successful toggle of a feature
  def success_message
    "Feature #{params[:feature]} is now #{session[params[:feature]]}"
  end

  # message to display if feature toggle was not valid
  def failure_message
    "#{params[:feature]} is not a valid feature"
  end

  # Ensure the feature parameter was included
  def validate_feature!
    return if params[:feature].present? && legit_feature?
    flash[:error] = failure_message
    redirect_to root_url
  end

  # Another layer of security around malicious manipulating of the session by
  # ensuring the session key being set, which indeed comes from a query
  # parameter, is one we legitamately expect. The `before_action` should prevent
  # this from ever being a problem, but setting session keys based on user
  # supplied parameters should be done with enough caution that this extra
  # method is worthwhile.
  def legit_feature
    return unless legit_feature?
    params[:feature]
  end

  # Confirms the feature is indeed one recognized by the application
  def legit_feature?
    Flipflop.feature_set.features.map(&:name).include?(params[:feature])
  end
end
