class SessionController < ApplicationController
  def box_toggler
    if helpers.box_enabled?(params[:box])
      remove_box
    else
      add_box
    end
    redirect_back fallback_location: root_url
  end

  private

  def remove_box
    session[:boxes].delete(params[:box])
  end

  def add_box
    session[:boxes].push(params[:box])
  end
end
