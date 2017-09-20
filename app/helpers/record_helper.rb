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

  # User is a guest and the link is restricted
  def guest_and_restricted_link?
    guest? && @record.fulltext_link[:url] == 'detail'
  end
end
