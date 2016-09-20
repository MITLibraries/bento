class SearchController < ApplicationController
  def index
  end

  def bento
  end

  def search
    unless strip_q.present?
      flash[:error] = 'A search term is required.'
      return redirect_to search_url
    end

    @results = search_target
    return redirect_to search_url unless @results
    render layout: false
  end

  private

  def search_target
    case params[:target]
    when 'articles'
      articles
    when 'books'
      books
    when 'google'
      google
    end
  end

  def today
    Time.zone.today.strftime('%Y%m%d')
  end

  # NOTE: The cache keys used below use a combination of the api endpoint
  # name, the search parameter, and today's date to allow us to cache calls
  # for the current date without ever worrying about expiring caches.
  # Instead, we'll rely on the cache itself to expire the oldest cached
  # items when necessary.
  def articles
    Rails.cache.fetch("articles_#{params[:q]}_#{today}") do
      SearchEds.new.search(strip_q, ENV['EDS_NO_ALEPH_PROFILE'])
    end
  end

  def books
    Rails.cache.fetch("books_#{params[:q]}_#{today}") do
      SearchEds.new.search(strip_q, ENV['EDS_ALEPH_PROFILE'])
    end
  end

  def google
    Rails.cache.fetch("google_#{strip_q}_#{today}") do
      SearchGoogle.new.search(strip_q)
    end
  end

  def strip_q
    params[:q].strip
  end
end
