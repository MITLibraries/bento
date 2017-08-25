module RecordHelper
  def local_record?
    aleph_record? || aleph_cr_record?
  end

  def local_book?
    if book_like.include?(@record.eds_publication_type)
      true
    else
      false
    end
  end

  def book_like
    %w[Book]
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
