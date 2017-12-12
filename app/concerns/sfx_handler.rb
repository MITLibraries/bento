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
                 title: nil)
    @barcode = barcode
    @call_number = call_number
    @collection = collection
    @doc_number = doc_number
    @title = title
    @library = library
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
    encoded_title = ERB::Util.url_encode(@title)

    # Yes, sometimes we double-encode, so that when SFX passes parameters
    # through its next step they end up as hoped.
    if scan
      encoded_title = ERB::Util.url_encode(encoded_title)
      analytics = 'BENTO'
    else
      # Things with analytics=BENTO are automatically routed through scan &
      # deliver by SFX. That's great if we want to scan, but not great if we
      # don't. Since this URL is used as a fallback - when all other options
      # have failed - we have no idea what we're dealing with and it could be
      # an object unsuitable for scan (e.g. audiotape, large-format map,
      # entire book).
      analytics = 'BENTO_FALLBACK'
    end

    # The call number is important! In Barton we use different URL parameters
    # for request items, but this ends up with scan requests for Technique
    # (the yearbook) being routed to a Polish land use journal. Call number
    # fixes this bug and does not seem to introduce new ones.
    encoded_call_no = ERB::Util.url_encode(@call_number)

    url_parts = [
      sfx_host.to_s,
      "?sid=ALEPH:#{analytics}",
      "&amp;call_number=#{encoded_call_no}",
      "&amp;barcode=#{@barcode}",
      "&amp;title=#{encoded_title}",
      "&amp;location=#{encoded_location}"
    ]

    if @doc_number
      url_parts.push(
        "&amp;pid=DocNumber=#{@doc_number},Ip=library.mit.edu,Port=9909"
      )
    end

    if scan
      url_parts.push('&amp;genre=journal')
    end

    url_parts.join('')
  end

  def encoded_location
    location = if @collection == 'Off Campus Collection'
                 'OCC'
               else
                 @library
               end
    ERB::Util.url_encode(ERB::Util.url_encode(location))
  end

  def sfx_host
    if Rails.env.production?
      'https://sfx.mit.edu/sfx_local'
    else
      'https://sfx.mit.edu/sfx_test'
    end
  end
end
