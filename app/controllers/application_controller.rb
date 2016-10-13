class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :enable_boxes

  def new_session_path(_scope)
    root_path
  end

  # Set which boxes are enabled
  def enable_boxes
    return if session[:boxes]
    session[:boxes] = ENV['ENABLED_BOXES'].split(',')
  end
end
