# Common model to store Result metadata
class Result
  include ActiveModel::Validations
  validates :title, presence: true
  validates :url, presence: true

  attr_accessor :title, :year, :url, :type, :authors, :citation, :online,
                :year, :type, :in, :publisher, :location, :blurb, :subjects,
                :available_url, :thumbnail, :get_it_label, :get_it_url,
                :db_source, :an, :custom_link

  def initialize(title, url)
    @title = title
    @url = url
  end

  def clean_an
    an.split('.').last.prepend('MIT01')
  end

  # View-type method for returning a truncated list of authors.
  def truncated_authors
    return authors if authors.length <= ENV['MAX_AUTHORS'].to_i
    authors[0...ENV['MAX_AUTHORS'].to_i] << 'et al'
  end

  def truncated_subjects
    subjects[0..2]
  end

  def aleph_record?
    if an.present? && an.start_with?('mit.')
      true
    else
      false
    end
  end
end
