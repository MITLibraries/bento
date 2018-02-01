module RecordHelper
  def local_record?
    aleph_record? || aleph_cr_record?
  end

  # Link to local source record
  def local_record_source_url
    if aleph_record?
      'https://library.mit.edu/item/' \
        "#{an_numeric_component}"
    elsif aleph_cr_record?
      'https://library.mit.edu/res/' \
        "#{an_numeric_component}"
    end
  end

  # Link to record in EDS.
  def eds_link
    "#{@record.eds_plink.gsub('&authtype=sso', '')}#{ENV['EDS_PLINK_APPEND']}"
  end

  # Get the numeric portion of the accession number (without the collection
  # label).
  def an_numeric_component
    @record.eds_accession_number.split('.').last
  end

  # Reformat the Accession Number to match the format used in Aleph
  def clean_an
    if aleph_record?
      an_numeric_component.prepend('MIT01')
    elsif aleph_cr_record?
      an_numeric_component.prepend('MIT30')
    end
  end

  # Detects local aleph course reserve records
  def aleph_cr_record?
    if @record.eds_accession_number.present? &&
       @record.eds_accession_number.start_with?('mitcr.')
      true
    else
      false
    end
  end

  # Detects local aleph records
  def aleph_record?
    if @record.eds_accession_number.present? &&
       @record.eds_accession_number.start_with?('mit.')
      true
    else
      false
    end
  end

  # If the top EDS fulltext link is an SFX link that does NOT go directly to a
  # fulltext resource, we want to present an unstyled link to check for
  # fulltext online. Otherwise, we want an attention-getting 'view online'
  # button.
  def check_online?
    url = @record.fulltext_link[:url]
    # SFX URLs observed in the wild: owens.mit.edu/sfx_local,
    # sfx.mit.edu/sfx_local, library.mit.edu/?func=service-sfx
    url.present? && (
        @record.fulltext_link[:label] == 'Check SFX for availability'
    )
  end

  # domains we consider relevant when evaluating links
  def relevant_links
    ['libproxy.mit.edu', 'library.mit.edu', 'sfx.mit.edu', 'owens.mit.edu',
     'libraries.mit.edu', 'content.ebscohost.com']
  end

  # Check fulltext_link to confirm it has a domain from relevant_links
  def relevant_fulltext_link?(link)
    relevant_links.map { |x| link[:url].include?(x) }.any?
  end

  # The value in @record.eds_languages is sometimes a string and sometimes an
  # array. We're going to make it always be an array, so we can handle it in
  # the same way in the template regardless, and also use its arrayness to
  # pluralize "language" properly.
  def clean_language
    if @record.eds_languages.is_a? String
      @record.eds_languages.gsub(/\s+/, '').split(',')
    else
      @record.eds_languages
    end
  end

  def clean_affiliations
    return if @record.eds_author_affiliations.blank?
    affs = Nokogiri::HTML.fragment(
      CGI.unescapeHTML(@record.eds_author_affiliations)
    )
    affs.search('relatesto').each(&:remove)
    nodes = affs.children.map(&:text).map(&:strip)
    nodes.reject!(&:empty?)
    nodes.reject! { |c| c == '&lt;br /&gt;' }
    nodes
  end

  def clean_other_titles
    return if @record.eds_other_titles.blank?
    titles = Nokogiri::HTML.fragment(CGI.unescapeHTML(@record.eds_other_titles))
    titles.search('searchlink').map(&:text).map(&:strip)
  end

  def path_to_previous
    # Don't use q as the parameter here - that will cause the search form to
    # notice the parameter and prefill the search, which is behavior we *don't*
    # want.
    params[:previous]
  end

  # Turns out metadata in the wild can include HTML markup, which is encoded and
  # rendered as strings, such as a user-visible "<br />". Let's not do that.
  # Instead, let's strip potentially dangerous tags but render the rest.
  # Nokogiri is being used because it is :rainbow: at handling poorly formed
  # HTML, which appears to be the norm.
  def safe_output(input)
    sanitize Nokogiri::HTML.fragment(CGI.unescapeHTML(input)).to_s
  end

  # link is a direct expiring pdflink
  def restricted_link?
    @record.fulltext_link[:expires] == true
  end

  # User is a guest and the link is restricted
  def guest_and_restricted_link?
    guest? && restricted_link?
  end

  # force http images to use https. If remote server cannot handle https a
  # broken image is expected. The `alt` keyword argument is required for
  # accessibility reasons and is a keyword argument instead of positional to
  # match the syntax of `image_tag` which this wraps.
  def force_https_image_tag(url, alt:)
    image_tag(force_https(url), alt: alt)
  end

  # force scheme of a url to https if it is currently http. if it is not http
  # just return the input with no changes
  def force_https(url)
    uri = URI(url)
    return url unless uri.scheme == 'http'
    uri.scheme = 'https'
    uri.to_s
  end

  # Determine scan exclusions based on cataloged subject headings
  def scan?
    return true if @subjects.blank?
    return true if ENV['SCAN_EXCLUSIONS'].blank?
    scannable_subject_heading?
  end

  # If any subject in the record matches any excluded subject it is unscannable
  def scannable_subject_heading?
    excluded_subjects.map { |exclude| @subjects.include?(exclude) }.none?
  end

  def excluded_subjects
    ENV['SCAN_EXCLUSIONS'].split(';')
  end
  def full_record_toggle_link
    link_text = if Flipflop.local_full_record?
                  'Turn off beta "Details and requests" view'
                else
                  'Try our beta "Details and requests" view'
                end
    link_to(link_text, full_record_toggle_path)
  end

  # Returns the name of the partial we should use to render our 'view online'
  # button. (There are different URL sources, link texts, and styling depending
  # on various parameters, and the logic is too involved to belong in a view.)
  def availability_action
    # SFX links that we don't know for sure if we own; auth happens at SFX.
    # The check_online template requires an @sfx_link value to be set.
    if check_online?
      @sfx_link = @record.fulltext_link[:url]
      'availability_check_online'

    # Links is expiring / restricted so we can only show to affiliates.
    elsif guest_and_restricted_link?
      'availability_restricted'

    # Restricted expiring link, but current user is allowed to access it.
    # We'll get a fresh version of the link and redirect them to it.
    elsif restricted_link?
      'availability_expiring'

    # Non restricted full text link (usually authenticated through SFX).
    elsif relevant_fulltext_link?(@record.fulltext_link)
      'availability_full'

    # When all else fails, make SFX sort it out.
    else
      @sfx_link = SFXHandler.new(
        title: @record.eds_title,
        doc_number: clean_an,
      ).url_generic
      'availability_check_online'
    end
  end

  def map_record_type(record)
    r_types = {
      "Academic Journal" => "Journal Article",
      "Magazines" => "Magazine Article",
      "Trade Publications" => "Magazine Article",
      "News" => "Newspaper Article",
      "Books" => "Book",
      "Reviews" => "Journal Article",
      "Reports" => "Report",
      "Conference Materials" => "Conference Paper",
      "Dissertations/Theses" => "Thesis",
      "Biographies" => "Book",
      "Primary Source Documents" => "Manuscript",
      "Government Documents" => "Report",
      "Music Score" => "Document",
      "Research Starters" => "Webpage",
      "Electronic Resources" => "Webpage",
      "Non-Print Resources" => "Webpage",
      "Audio" => "Audio Recording",
      "Videos" => "Video Recording",
      "eBooks" => "Book",
      "Maps" => "Map"
    }
    r_types[record.eds_publication_type] || record.eds_publication_type
  end

  # Extract summary holdings from @record.eds_extras_NoteSerial
  # see: https://mitlibraries.atlassian.net/browse/DI-547 for background.
  # We need to handle cases where NoteSerial has no Summary Holdings, one
  # summary holding after a Note, multiple summary holdings after a note,
  # one or multiple summary holdings with no notes preceding.
  # Summary Holdings are preceded by `[s_h]` in the string and may or may not
  # exist.
  def summary_holdings(note)
    sh_count = note.scan('[s_h]').count
    split_sh = note.split('[s_h]').map(&:strip)

    if sh_count == split_sh.count
      split_sh
    elsif sh_count == split_sh.count - 1
      split_sh.drop(1)
    else
      Rails.logger.warn("Summary Holdings concern: #{note}")
      note
    end
  end
end
