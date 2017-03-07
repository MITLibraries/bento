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
    if marc_856
      best_link(marc_856, 'marc_856')
    elsif custom_link && custom_link_picker.present?
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

  # Check custom link for specific parameters to allow for prioritization
  def relevant_custom_link?(check)
    custom_link.map do |link|
      link['Url'].include?(check)
    end.include?(true)
  end

  # Only use links going through sfx or library as other direct links
  # may be to less useful things (like t.o.c.) or direct to publishers, which
  # while useful on campus, would not be useful off campus without adding
  # additional features to bento that are currently out of scope.
  def custom_link_picker
    clink = if relevant_custom_link?('sfx.mit.edu')
              custom_link.select do |link|
                link['Url'].include?('sfx.mit.edu')
              end
            elsif relevant_custom_link?('library.mit.edu')
              custom_link.select do |link|
                link['Url'].include?('library.mit.edu')
              end
            end
    clink.first['Url'] if clink
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
