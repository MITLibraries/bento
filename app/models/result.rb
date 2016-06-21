class Result
  include ActiveModel::Validations
  validates :title, presence: true
  validates :year, presence: true
  validates :url, presence: true
  validates :type, presence: true

  attr_accessor :title, :year, :url, :type, :authors, :citation, :online
  def initialize(title, year, url, type)
    @title = title
    @year = year
    @url = url
    @type = type
  end
end
