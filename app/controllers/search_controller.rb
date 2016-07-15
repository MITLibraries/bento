class SearchController < ApplicationController
  def index
  end

  def bento
    @results = SearchEds.new.search(params[:q])
  end
end
