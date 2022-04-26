class SearchController < ApplicationController
  before_action :validate_q!, only: %i[bento search search_boxed]

  class NoSuchTargetError < StandardError; end

  rescue_from NoSuchTargetError, with: :no_such_target

  def index; end

  def bento; end

  def search_boxed
    @per_box = (ENV['RESULTS_PER_BOX'] || 5).to_i
    @results = search_results(1, @per_box)
    render layout: false
  end

  def search
    page = params[:page] || 1
    per_page = params[:per_page] || ENV['PER_PAGE'] || 20
    @results = search_results(page, per_page)
    render 'search_boxed'
  end

  private

  # Requests results from requested target
  # NOTE: The cache keys used below use a combination of the api endpoint
  # name, the search parameter, and today's date to allow us to cache calls
  # for the current date without ever worrying about expiring caches.
  # Instead, we'll rely on the cache itself to expire the oldest cached
  # items when necessary.
  def search_results(page, per_page)
    Rails.cache.fetch(cache_key(page, per_page), expires_in: 1.day) do
      search_target(page, per_page)
    end
  end

  def cache_key(page, per_page)
    "#{params[:target]}_#{strip_truncate_q}_#{page}_#{per_page}_#{today}"
  end

  # Formatted date used in creating cache keys
  def today
    Time.zone.today.strftime('%Y%m%d')
  end

  def search_target(_page, per_page)
    case params[:target]
    when 'google'
      search_google
    when 'timdex'
      search_timdex
    when ENV['PRIMO_BOOK_SCOPE'], ENV['PRIMO_ARTICLE_SCOPE']
      search_primo(per_page)
    else
      raise SearchController::NoSuchTargetError
    end
  end

  # Searches Primo
  def search_primo(per_page)
    raw_results = SearchPrimo.new.search(strip_truncate_q, params[:target], per_page)
    NormalizePrimo.new.to_result(raw_results, params[:target], strip_truncate_q)
  end

  # Searches Google Custom Search
  def search_google
    raw_results = SearchGoogle.new.search(strip_truncate_q)
    NormalizeGoogle.new.to_result(raw_results, strip_truncate_q)
  end

  # Searches TIMDEX! API
  def search_timdex
    raw_results = SearchTimdex.new.search(strip_truncate_q)
    NormalizeTimdex.new.to_result(raw_results, strip_truncate_q)
  end

  # Strips trailing and leading white space in search term
  # Truncates long searches at whole words to prevent bugs with long terms.
  # Individual search engine models do additional cleaning as appropriate.
  def strip_truncate_q
    params[:q].strip.truncate((ENV['MAX_QUERY_LENGTH'] || 1500).to_i,
                              separator: ' ')
  end

  def validate_q!
    return if params[:q].present? && strip_truncate_q.present?

    flash[:error] = 'A search term is required.'
    redirect_to root_url
  end

  def no_such_target
    render 'errors/not_found', status: 404
  end
end
