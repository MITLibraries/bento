# Common model to store Result metadata
class Result
  include ActiveModel::Validations
  validates :title, presence: true
  validates :url, presence: true

  attr_accessor :an, :authors, :availability, :available_url, :blurb, 
                :check_sfx_url, :citation, :date_range, :db_source, :dedup_url,
                :fulltext_links, :get_it_label, :in, :location, :marc_856, 
                :online, :openurl, :other_availability, :physical_description, 
                :publisher, :record_links, :subjects, :thumbnail, :title, 
                :type, :uniform_title, :url, :winner, :year

  MAX_TITLE_LENGTH = ENV['MAX_TITLE_LENGTH'] || 150

  def initialize(title, url)
    @title = title
    @url = url
  end

  # Prioritizes the best link to use for the "get it" button in the UI
  def getit_url
    if marc_856 && relevant_marc_856?
      best_link(marc_856, 'marc_856')
    elsif fulltext_links && relevant_fulltext_links?
      best_link(fulltext_links_picker(true), 'eds fulltext')
    elsif Flipflop.enabled? :primo_search
      alma_link_resolver_url
    end
  end

  def alma_link_resolver_url
    self.openurl
  end

  # URL to use for check_sfx button in the UI
  def check_sfx_url
    fulltext_links_picker(false) if fulltext_links && relevant_fulltext_links?
  end

  def best_link(link, winner)
    self.winner = winner
    link
  end

  # ensure we care about the included marc_856 link
  def relevant_marc_856?
    relevant_links.map { |x| marc_856.include?(x) }.any?
  end

  # domains we consider relevant when evaluating links
  def relevant_links
    ['libproxy.mit.edu', 'library.mit.edu', 'sfx.mit.edu', 'owens.mit.edu',
     'libraries.mit.edu']
  end

  # Check fulltext_links for specific parameters to allow for prioritization
  def relevant_fulltext_links?
    fulltext_links.map do |link|
      relevant_links.map { |x| link['Url'].include?(x) }.any?
    end.include?(true)
  end

  # Exclude any links that include SFX link (not subscribed resources)
  # as a link['Name']
  def remove_not_subscribed_sfx_links(links)
    links.map do |l|
      l unless l['Name'].present? && l['Name'].include?('not subscribed')
    end
  end

  # Only use links going through sfx or library as other direct links
  # may be to less useful things (like t.o.c.) or direct to publishers, which
  # while useful on campus, would not be useful off campus without adding
  # additional features to bento that are currently out of scope.
  # `subscribed` is a boolean to signal whether to only include sfx links that
  # are highly likely to go directly to full text (i.e. we know we subscribe
  # to them or not)
  def fulltext_links_picker(subscribed)
    link = fulltext_links.map do |l|
      relevant_links.map { |x| l if l['Url'].include?(x) }.compact
    end
    links = if subscribed
              remove_not_subscribed_sfx_links(link.flatten)
            else
              link.flatten
            end
    fulltext_link_sorter(links).first if links
  end

  # prioritizes proxied links
  # this is really hack and only moves a specified match to the top and does
  # not allow for an actual custom sorted prioritization of links
  def fulltext_link_sorter(link)
    urls = link.flatten.compact.map { |x| x['Url'] }
    urls.sort do |x|
      if x.include?(relevant_links[0])
        -1
      else
        1
      end
    end
  end

  # Reformat the Accession Number to match the format used in Aleph
  def clean_an
    if aleph_record?
      an.split('.').last.prepend('MIT01')
    elsif aleph_cr_record?
      an.split('.').last.prepend('MIT30')
    elsif alma_record?
      an
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

  def alma_record?
    an.present? && an.start_with?('alma') ? true : false
  end
end
