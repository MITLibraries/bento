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
        "#{@record.eds_accession_number.split('.').last}"
    elsif aleph_cr_record?
      'https://library.mit.edu/res/' \
        "#{@record.eds_accession_number.split('.').last}"
    end
  end

  # Reformat the Accession Number to match the format used in Aleph
  def clean_an
    if aleph_record?
      @record.eds_accession_number.split('.').last.prepend('MIT01')
    elsif aleph_cr_record?
      @record.eds_accession_number.split('.').last.prepend('MIT30')
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
end
