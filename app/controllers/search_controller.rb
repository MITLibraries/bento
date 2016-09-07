class SearchController < ApplicationController
  def index
  end

  def bento
    # TODO: it's generally bad form to have multiple instance Variables
    # acessible in the views. However, this needs a refactor to allow for
    # async searching anyway so I'm violating that rule for now with the
    # anticipation of the async work.

    today = Time.zone.today.strftime('%Y%m%d')

    # NOTE: The cache keys used below use a combination of the api endpoint
    # name, the search parameter, and today's date to allow us to cache calls
    # for the current date without ever worrying about expiring caches.
    # Instead, we'll rely on the cache itself to expire the oldest cached
    # items when necessary.

    @articles = Rails.cache.fetch("articles_#{params[:q]}_#{today}") do
      SearchEds.new.search(params[:q], ENV['EDS_NO_ALEPH_PROFILE'])
    end

    @books = Rails.cache.fetch("books_#{params[:q]}_#{today}") do
      SearchEds.new.search(params[:q], ENV['EDS_ALEPH_PROFILE'])
    end

    @google = Rails.cache.fetch("google_#{params[:q]}_#{today}") do
      SearchGoogle.new.search(params[:q])
    end
  end
end
