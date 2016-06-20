class Result
  include ActiveModel::Validations
  validates_presence_of :title, :year, :url, :type

  attr_accessor :title, :year, :url, :type, :authors, :citation, :online
  def initialize(title, year, url, type)
    @title = title
    @year = year
    @url = url
    @type = type
  end
end
