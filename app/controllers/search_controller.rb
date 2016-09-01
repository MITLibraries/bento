class SearchController < ApplicationController
  def index
  end

  def bento
    @results = SearchEds.new.search(params[:q])

    # TODO: it's generally bad form to have multiple instance Variables
    # acessible in the views. However, this needs a refactor to allow for
    # async searching anyway so I'm violating that rule for now with the
    # anticipation of the async work.
    @moar_results = SearchGoogle.new.search(params[:q])
  end
end
