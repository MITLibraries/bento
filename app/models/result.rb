# Common model to store Result metadata
class Result
  include ActiveModel::Validations
  validates :title, presence: true
  validates :url, presence: true

  attr_accessor :an, :authors, :availability, :blurb, :citation, :dedup_url, :in, :link, :location, :openurl, 
                :other_availability, :physical_description, :publisher, :subjects, :thumbnail, :title, :type, :url, :year

  MAX_TITLE_LENGTH = ENV['MAX_TITLE_LENGTH'] || 150

  def initialize(title, url)
    @title = title
    @url = url
  end

  # Prioritizes the best link to use for the "get it" button in the UI
  def getit_url
    if Flipflop.enabled? :primo_search
      openurl
    end
  end

  # View-type method for returning a truncated list of authors.
  def truncated_authors
    return authors if authors.length <= ENV['MAX_AUTHORS'].to_i
    authors[0...ENV['MAX_AUTHORS'].to_i] << 'et al'
  end

  def truncated_blurb
    blurb.truncate(200, separator: ' ')
  end

  def truncated_physical
    physical_description.truncate(200, separator: ' ')
  end

  def truncated_subjects
    subjects[0..2]
  end

  def truncated_title
    title.truncate(MAX_TITLE_LENGTH, separator: ' ')
  end

  def alma_record?
    an.present? && an.start_with?('alma') ? true : false
  end
end
