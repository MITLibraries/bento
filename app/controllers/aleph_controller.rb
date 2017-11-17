class AlephController < ApplicationController
  # item_status and full_item_status render different html
  def item_status
    @status = AlephItem.new.items(params[:id], params[:oclc], params[:scan])
    render layout: false
  end

  # item_status and full_item_status render different html
  def full_item_status
    @status = AlephItem.new.items(params[:id], params[:oclc], params[:scan])
    render layout: false
  end
end
