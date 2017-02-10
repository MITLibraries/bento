class AlephController < ApplicationController
  def item_status
    @status = AlephItem.new.items(params[:id])
    render layout: false
  end
end
