class SFXHandler
  # The SFX server will do the best it can with whatever it has, so we will
  # initialize the SFXHandler with whatever data we happen to have. We're not
  # guaranteed to have all (or indeed any) of these objects; Aleph and EDS
  # provide different subsets of them. We provide default nil values so that
  # we don't have to pass parameters in when we don't have the corresponding
  # data.
  def initialize(barcode: nil,
                 call_number: nil,
                 collection: nil,
                 doc_number: nil,
                 library: nil,
                 title: nil,
                 year: nil,
                 volume: nil)
    @barcode = barcode
    @call_number = call_number
    @collection = collection
    @doc_number = doc_number
    @title = title
    @library = library
    @year = year
    @volume = volume
  end

  # Use this when you want to request a scan of an object.
  def url_for_scan
    url_constructor(scan: true)
  end

  # Use this when you just want SFX to make its best guess.
  def url_generic
    url_constructor
  end

  private

  def url_constructor(scan: false)
    url_parts = [
      sfx_host.to_s,
      "?sid=ALEPH:#{analytics(scan)}",
      "&amp;call_number=#{encoded_call_no}",
      "&amp;barcode=#{@barcode}",
      "&amp;title=#{encoded_title}",
      "&amp;location=#{encoded_location}",
      "&amp;rft.date=#{@year}",
      "&amp;rft.volume=#{@volume}"
    ]

    url_parts.push(pid) if @doc_number
    url_parts.push('&amp;genre=journal') if scan
    url_parts.join('')
  end

  # Things with analytics=BENTO are automatically routed through scan &
  # deliver by SFX. That's great if we want to scan, but not great if we
  # don't. Since this URL is used as a fallback - when all other options
  # have failed - we have no idea what we're dealing with and it could be
  # an object unsuitable for scan (e.g. audiotape, large-format map,
  # entire book).
  def analytics(scan)
    if scan
      'BENTO'
    else
      'BENTO_FALLBACK'
    end
  end

  # The call number is important! In Barton we use different URL parameters
  # for request items, but this ends up with scan requests for Technique
  # (the yearbook) being routed to a Polish land use journal. Call number
  # fixes this bug and does not seem to introduce new ones.
  def encoded_call_no
    URI.encode_www_form_component(@call_number)
  end

  def encoded_location
    location = if @collection == 'Off Campus Collection'
                 'OCC'
               else
                 @library
               end
    URI.encode_www_form_component(location)
  end

  def encoded_title
    URI.encode_www_form_component(@title)
  end

  def pid
    "&amp;pid=DocNumber=#{@doc_number},Ip=library.mit.edu,Port=9909"
  end

  def sfx_host
    if Rails.env.production?
      'https://sfx.mit.edu/sfx_local'
    else
      'https://sfx.mit.edu/sfx_test'
    end
  end
end
