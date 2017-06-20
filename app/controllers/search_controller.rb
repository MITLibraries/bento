class SearchController < ApplicationController
  before_action :validate_q!, only: %i[bento search search_boxed]

  def index; end

  def bento; end

  def search_boxed
    @per_box = (ENV['RESULTS_PER_BOX'] || 5).to_i
    @results = search_results(1, @per_box)
    return redirect_to root_url unless @results
    render layout: false
  end

  def search
    page = params[:page] || 1
    per_page = params[:per_page] || ENV['PER_PAGE'] || 20
    @results = search_results(page, per_page)
    @pageable_results = paginate_results(page, per_page)
    return redirect_to root_url unless @results
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
    return unless valid_target?
    Rails.cache.fetch(cache_key(page, per_page)) do
      search_target(page, per_page)
    end
  end

  def cache_key(page, per_page)
    "#{params[:target]}_#{strip_truncate_q}_#{page}_#{per_page}_#{today}"
  end

  # Boolean check of whether param passed in is a valid search endpoint
  def valid_target?
    valid_targets.include?(params[:target])
  end

  # Array of search endpoints that are supported
  def valid_targets
    %w[articles books google]
  end

  # Formatted date used in creating cache keys
  def today
    Time.zone.today.strftime('%Y%m%d')
  end

  def search_target(page, per_page)
    if params[:target] == 'google'
      search_google
    else
      search_eds(page, per_page)
    end
  end

  # Seaches EDS
  def search_eds(page, per_page)
    raw_results = SearchEds.new.search(
      strip_truncate_q, ENV['EDS_PROFILE'], eds_facets, page, per_page
    )
    NormalizeEds.new.to_result(raw_results, params[:target], strip_truncate_q)
  end

  def eds_facets
    if params[:target] == 'articles'
      ENV['EDS_ARTICLE_FACETS']
    elsif params[:target] == 'books'
      ENV['EDS_BOOK_FACETS']
    end
  end

  # Searches Google Custom Search
  def search_google
    raw_results = SearchGoogle.new.search(strip_truncate_q)
    NormalizeGoogle.new.to_result(raw_results, strip_truncate_q)
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

  # Turns search results into a format that can be used by the paginator.
  def paginate_results(page, per_page)
    # EDS API Limits retrieving results past about 250
    max = [@results['total'], 250].min
    Kaminari.paginate_array(
      @results['results'],
      total_count: max
    ).page(page).per(per_page)
  end
end
