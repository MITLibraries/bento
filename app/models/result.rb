# Common model to store Result metadata
class Result
  include ActiveModel::Validations
  validates :title, presence: true
  validates :url, presence: true

  attr_accessor :title, :year, :url, :type, :authors, :citation, :online,
                :year, :type, :in, :publisher, :location, :blurb, :subjects,
                :available_url, :thumbnail, :get_it_label,
                :db_source, :an, :fulltext_links, :marc_856, :openurl,
                :winner, :record_links

  def initialize(title, url)
    @title = title
    @url = url
  end

  # Prioritizes the best link to use for the "get it" button in the UI
  def getit_url
    if marc_856 && relevant_marc_856?
      best_link(marc_856, 'marc_856')
    elsif fulltext_links && relevant_fulltext_links?
      best_link(fulltext_links_picker, 'eds fulltext')
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

  # Check fulltext_links for specific parameters to allow for prioritization
  def relevant_fulltext_links?
    fulltext_links.map do |link|
      relevant_links.map { |x| link['Url'].include?(x) }.any?
    end.include?(true)
  end

  # Only use links going through sfx or library as other direct links
  # may be to less useful things (like t.o.c.) or direct to publishers, which
  # while useful on campus, would not be useful off campus without adding
  # additional features to bento that are currently out of scope.
  def fulltext_links_picker
    link = fulltext_links.map do |l|
      relevant_links.map { |x| l if l['Url'].include?(x) }
    end
    link.flatten.compact.first['Url'] if link
  end

  # Reformat the Accession Number to match the format used in Aleph
  def clean_an
    if aleph_record?
      an.split('.').last.prepend('MIT01')
    elsif aleph_cr_record?
      an.split('.').last.prepend('MIT30')
    end
  end

  # View-type method for returning a truncated list of authors.
  def truncated_authors
    return authors if authors.length <= ENV['MAX_AUTHORS'].to_i
    authors[0...ENV['MAX_AUTHORS'].to_i] << 'et al'
  end

  def truncated_subjects
    subjects[0..2]
  end

  def aleph_cr_record?
    if an.present? && an.start_with?('mitcr.')
      true
    else
      false
    end
  end

  def aleph_record?
    if an.present? && an.start_with?('mit.')
      true
    else
      false
    end
  end
end
