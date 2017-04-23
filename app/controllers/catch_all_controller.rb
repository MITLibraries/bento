class CatchAllController < ApplicationController
  def catch_all
    respond_to do |format|
      format.html { render status: 404 }
      format.all { head 404 }
    end
  end

  def broken_intentionally
    break_stuff
  end
end
