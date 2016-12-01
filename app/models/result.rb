# Common model to store Result metadata
class Result
  include ActiveModel::Validations
  validates :title, presence: true
  validates :url, presence: true

  attr_accessor :title, :year, :url, :type, :authors, :citation, :online,
                :year, :type, :in, :publisher, :location, :blurb, :subjects,
                :available_url, :thumbnail, :get_it_url, :db_source

  def initialize(title, url)
    @title = title
    @url = url
  end

  # View-type method for returning a truncated list of authors.
  def truncated_authors
    return authors if authors.length <= ENV['MAX_AUTHORS'].to_i
    authors[0...ENV['MAX_AUTHORS'].to_i] << 'et al'
  end

  def truncated_subjects
    subjects[0..2]
  end

  def order
    [
      'Hayden Library - Stacks',
      'Hayden Library - Browsery',
      'Hayden Library - Science Oversize Materials',
      'Hayden Library - Humanities Media'
    ]
  end

  # show one library that has it available according to our preference order:
  # Internet resource, Hayden, Barker, Rotch, Dewey, Lewis, Hayden Reserves
  # Rotch Visual, LSA, IASC, Physics reading room
  def prioritized_location
    location.sort_by do |loc|
      if order.index(loc[0])
        order.index(loc[0])
      else
        100
      end
    end
  end
end
