module RecordHelper
  def local_record?
    aleph_record? || aleph_cr_record?
  end

  # determines if an item is serial-ish or monograph-ish to help us determine
  # if we should use holdings records or item records for realtime status
  def non_serial?
    if book_like.include?(@record.eds_publication_type)
      true
    else
      false
    end
  end

  # Publication types that we want to treat like books
  def book_like
    ['Book', 'Audio', 'Video Recording']
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
      url.match?('mit.edu/sfx') || url.match?('func=service-sfx')) && (
        @record.fulltext_link[:label] == 'Check SFX for availability'
      )
  end
end
