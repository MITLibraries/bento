# Common model to store Result metadata
class Result
  include ActiveModel::Validations
  validates :title, presence: true
  validates :url, presence: true

  attr_accessor :title, :year, :url, :type, :authors, :citation, :online,
                :year, :type, :in, :publisher, :location, :blurb, :subjects,
                :available_url, :thumbnail, :get_it_label,
                :db_source, :an, :custom_link, :marc_856, :openurl,
                :winner

  def initialize(title, url)
    @title = title
    @url = url
  end

  # Prioritizes the best link to use for the "get it" button in the UI
  def getit_url
    if marc_856 && relevant_marc_856?
      best_link(marc_856, 'marc_856')
    elsif custom_link && relevant_custom_link?
      best_link(custom_link_picker, 'custom_link')
    elsif openurl
      best_link(openurl, 'openurl')
    else
      best_link(url, 'url')
    end
  end

  def best_link(link, winner)
    self.winner = winner
    link
  end

  # ensure we care about the included marc_856 link
  def relevant_marc_856?
    relevant_links.map { |x| marc_856.include?(x) }.any?
  end

  def relevant_links
    ['library.mit.edu', 'sfx.mit.edu', 'owens.mit.edu']
  end

  # Check custom link for specific parameters to allow for prioritization
  def relevant_custom_link?
    custom_link.map do |link|
      relevant_links.map { |x| link['Url'].include?(x) }.any?
    end.include?(true)
  end

  # Only use links going through sfx or library as other direct links
  # may be to less useful things (like t.o.c.) or direct to publishers, which
  # while useful on campus, would not be useful off campus without adding
  # additional features to bento that are currently out of scope.
  def custom_link_picker
    c_link = custom_link.map do |link|
      relevant_links.map { |x| link if link['Url'].include?(x) }
    end
    c_link.flatten.compact.first['Url'] if c_link
  end

  # Reformat the Accession Number to match the format used in Aleph
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
