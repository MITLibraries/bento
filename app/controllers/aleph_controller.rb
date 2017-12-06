class AlephController < ApplicationController
  caches_action :full_item_status, expires_in: 15.minutes,
                                   cache_path: :cache_path
  caches_action :item_status, expires_in: 15.minutes, cache_path: :cache_path

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

  protected

  # This is effectively a cache key based on the parameters we care about.
  # Note: aleph cache is not guest dependent so we can just use parameters for
  # the key.
  def cache_path
    url_for(
      id: params[:id],
      oclc: params[:oclc],
      scan: params[:scan],
      method: action_name
    )
  end
end
