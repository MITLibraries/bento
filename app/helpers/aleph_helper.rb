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
      'https://libraries.mit.edu/barker/'
    elsif library == 'Dewey Library'
      'https://libraries.mit.edu/dewey/'
    elsif library == 'Hayden Library'
      'https://libraries.mit.edu/hayden/'
    elsif library == 'Institute Archives'
      'https://libraries.mit.edu/archives/'
    elsif library == 'Lewis Music Library'
      'https://libraries.mit.edu/music/'
    elsif library == 'Rotch Library'
      'https://libraries.mit.edu/rotch/'
    elsif library == 'Library Storage Annex'
      'https://libraries.mit.edu/lsa/'
    end
  end
end
