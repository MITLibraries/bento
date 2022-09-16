class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper Mitlibraries::Theme::Engine.helpers

  def flipflop_access_control
    return if session[:flipflop_user]

    head :forbidden unless valid_flipflop_key?
    session[:flipflop_user] = true
  end

  private

  def valid_flipflop_key?
    return if params[:flipflop_key].blank?

    params[:flipflop_key] == ENV['FLIPFLOP_KEY']
  end
end
