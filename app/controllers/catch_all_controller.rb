class CatchAllController < ApplicationController
  def catch_all
    render status: 404
  end
end
