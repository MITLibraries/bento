class CatchAllController < ApplicationController
  def catch_all
    render status: 404
  end

  def broken_intentionally
  end
end
