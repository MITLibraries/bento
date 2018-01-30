module AlephHelper
  # detect media call number prefixes. can be used to exclude some types of
  # material from receiving UI features. i.e. DVD does not get photocopy button
  def media?(call_number)
    call_number.start_with?('AUDIO', 'AUDTAPE', 'CD', 'CDROM', 'DSKETTE',
                            'DVD', 'DVDROM', 'USB DRIVE', 'VDISC', 'VIDEO')
  end

  def archives?(library)
    library == 'Institute Archives'
  end

  # generates a link to an map for each library on campus
  def map_link(library)
    if library == 'Barker Library'
      'https://libraries.mit.edu/locations/#!barker-library'
    elsif library == 'Dewey Library'
      'https://libraries.mit.edu/locations/#!dewey-library'
    elsif library == 'Hayden Library'
      'https://libraries.mit.edu/locations/#!hayden-library'
    elsif library == 'Institute Archives'
      'https://libraries.mit.edu/locations/#!institute-archives-special-collections'
    elsif library == 'Lewis Music Library'
      'https://libraries.mit.edu/locations/#!lewis-music-library'
    elsif library == 'Rotch Library'
      'https://libraries.mit.edu/locations/#!rotch-library'
    elsif library == 'Library Storage Annex'
      'https://libraries.mit.edu/locations/#!library-storage-annex'
    end
  end

  # Special case for direct to aleph record links when starting from aleph data
  # and not EDS data (i.e. when we are dealing with realtime info).
  # Use the RecordHelper#local_record_source_url for most use cases.
  #     http://library.mit.edu/F/?func=item-global&doc_library=MIT01&doc_number=000297056
  def aleph_holdings_link(id)
    split_id = split_id(id)
    "https://library.mit.edu/F/?func=item-global&doc_library=#{split_id[0]}&doc_number=#{split_id[1]}"
  end

  # Returns an array with the first element being the aleph library and the
  # second being the record id.
  def split_id(id)
    if id.start_with?('MIT01')
      ['MIT01', id.gsub('MIT01', '')]
    elsif id.start_with?('MIT30')
      ['MIT30', id.gsub('MIT30', '')]
    else
      raise 'Invalid Aleph ID provided. Cannot construct URL to Aleph.'
    end
  end
end
