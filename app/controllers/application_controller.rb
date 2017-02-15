class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def new_session_path(_scope)
    root_path
  end

  def debug
    session[:debug] = session[:debug].!
    flash[:info] = "Your debug mode is now: #{session[:debug]}"
    redirect_to root_path
  end
end
