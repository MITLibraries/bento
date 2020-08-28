# Creates a Button with an actionable URL for items that allow reqeusts via SFX
# The primary intent is to use this for our relaunch of services after being
# all remote for the pandemic
class ButtonRequestDigital
  include ButtonMaker

  def construct_sfx_link
    SFXHandler.new(
      barcode: @barcode,
      call_number: @call_number,
      collection: @collection,
      library: @library,
      title: @title,
      doc_number: @doc_number,
      year: @year,
      volume: @volume,
      sid: 'ALEPH:MIT50'
    ).url_for_scan
  end

  def link_text  
    'Request digital copy'
  end

  def html_button
    return unless eligible?
    "<a class='btn button-secondary button-small' href=#{construct_sfx_link}>#{link_text}</a>"
  end

  # https://docs.google.com/document/d/15Z6gAu4E0784QwYEXH-6kcO8TqHVTfoe_i-dzusGPt8/edit#heading=h.aldraxogy28l
  def eligible?
    return false if Flipflop.enabled?(:disable_request_digital)
    [
      call_number_valid?,
      z30status_valid?,
      collection_valid?,
      status_valid?,
      library_valid?,
      !unscannable_standard?
    ].all?
  end

  def library_valid?
    ['Physics Dept. Reading Room', 'Rotch Visual Collections',
     'Institute Archives'].exclude? @library
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
      'Travel Collection',
      'Grammar Books',
      'Graphic Novels',
      'Humanities & Science New Books',
      'Humanities & Science New Journals',
      'Humanities & Science Temporary Collection',
      'Request via WorldCat',
      'Travel Books'
    ].include? @collection
  end

  def z30status_valid?
    [
      '01',
      '04',
      '20',
      '14',
      '13',
      '57',
      '15',
    ].include? @z30status_code
  end

  def call_number_valid?
    !@call_number.start_with?('ARCH DRAW', 'ATLAS', 'AUDIO', 'AUDTAPE', 'CD',
                              'CDROM', 'DSKETTE', 'DVD', 'DVDROM', 'FICHE',
                              'FILM', 'FOLIO', 'INDEX', 'MAP', 'MFILM',
                              'OVRSIZE', 'RECORD', 'REGULAR', 'SCORE', 'SMALL',
                              'THESIS', 'USB DRIVE', 'VDISC', 'VIDEO')
  end

  def status_valid?
    ['Archives Reading Room Use Only', 'LSA Room Use Only', 'Received'].exclude?(@status)
  end

  # We don't scan certain engineering standards. See
  # https://wikis.mit.edu/confluence/x/5igEBw for a link to the relevant
  # spreadsheet.
  def unscannable_standard?
    @scan == 'false'
  end
end
