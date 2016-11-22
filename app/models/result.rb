# Common model to store Result metadata
class Result
  include ActiveModel::Validations
  validates :title, presence: true
  validates :url, presence: true

  attr_accessor :title, :year, :url, :type, :authors, :citation, :online,
                :year, :type, :in, :publisher, :location, :blurb, :subjects,
                :available_url, :thumbnail

  def initialize(title, url)
    @title = title
    @url = url
  end

  # View-type method for returning a truncated list of authors.
  def truncated_authors
    return authors if authors.length <= ENV['MAX_AUTHORS'].to_i
    authors[0...ENV['MAX_AUTHORS'].to_i] << 'et al'
  end
end
