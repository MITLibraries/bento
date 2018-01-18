module AlephHelper
  # detect media call number prefixes. can be used to exclude some types of
  # material from receiving UI features. i.e. DVD does not get photocopy button
  def media?(call_number)
    call_number.start_with?('AUDIO', 'AUDTAPE', 'CD', 'CDROM', 'DSKETTE',
                            'DVD', 'DVDROM', 'USB DRIVE', 'VDISC', 'VIDEO')
  end

  def reserve?(collection)
    collection == 'Reserve Stacks'
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
end
