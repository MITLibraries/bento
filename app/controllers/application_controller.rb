class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def flipflop_access_control
    head :forbidden unless valid_flipflop_key?
  end

  def new_session_path(_scope)
    root_path
  end

  private

  def valid_flipflop_key?
    return if params[:flipflop_key].blank?
    params[:flipflop_key] == ENV['FLIPFLOP_KEY']
  end
end
