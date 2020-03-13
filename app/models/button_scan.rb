# Creates a Button with an actionable URL for items that can be scanned.
class ButtonScan
  include ButtonMaker

  def html_button
    return unless eligible?
    "<a class='btn button-secondary button-small'" \
    " title='You can request articles or chapters of books'" \
    " href='#{url}'>Request scan (2-3 days)</a>"
  end

  # We do not allow patrons to request electronic scans of all materials.
  # Sometimes this is a policy issue; sometimes it's a physical impossibility
  # issue, like "item is not in the library right now" or "item is an audio
  # tape".
  def eligible?
    return false if Flipflop.enabled?(:disable_scans) 
    [
      call_number_valid?,
      z30status_valid?,
      collection_valid?,
      status_valid?,
      library_valid?,
      !unscannable_standard?
    ].all?
  end

  def url
    SFXHandler.new(
      barcode: @barcode,
      call_number: @call_number,
      collection: @collection,
      library: @library,
      title: @title,
      year: @year,
      volume: @volume
    ).url_for_scan
  end

  # ~~~~~~~~ Utility functions needed to determine PDF scan eligibility ~~~~~~~~
  def call_number_valid?
    !@call_number.start_with?('ARCH DRAW', 'ATLAS', 'AUDIO', 'AUDTAPE', 'CD',
                              'CDROM', 'DSKETTE', 'DVD', 'DVDROM', 'FICHE',
                              'FILM', 'FOLIO', 'INDEX', 'MAP', 'MFILM',
                              'OVRSIZE', 'RECORD', 'REGULAR', 'SCORE', 'SMALL',
                              'THESIS', 'USB DRIVE', 'VDISC', 'VIDEO')
  end

  def z30status_valid?
    [
      '60 Day Loan',
      'One Week Loan',
      '1 Week No Renew',
      'OCC 60',
      'LSA 7',
      'LSA 60',
      'LSA Use Only'
    ].include? @z30status
  end

  def collection_valid?
    [
      'Stacks',
      'Journal Collection',
      'Off Campus Collection',
      'Science Journals',
      'Humanities Journals',
      'Impulse Borrowing Display',
      'Browsery',
      'Graphic Novel Collection',
      'Travel Collection'
    ].include? @collection
  end

  def status_valid?
    ['In Library', 'New Books Displ'].include?(@status)
  end

  def library_valid?
    ['Physics Dept. Reading Room', 'Rotch Visual Collections',
     'Institute Archives'].exclude? @library
  end

  # We don't scan certain engineering standards. See
  # https://wikis.mit.edu/confluence/x/5igEBw for a link to the relevant
  # spreadsheet.
  def unscannable_standard?
    @scan == 'false'
  end
end
