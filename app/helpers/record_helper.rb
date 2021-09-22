module RecordHelper
  # Turns out metadata in the wild can include HTML markup, which is encoded and
  # rendered as strings, such as a user-visible "<br />". Let's not do that.
  # Instead, let's strip potentially dangerous tags but render the rest.
  # Nokogiri is being used because it is :rainbow: at handling poorly formed
  # HTML, which appears to be the norm.
  def safe_output(input)
    sanitize Nokogiri::HTML.fragment(CGI.unescapeHTML(input)).to_s
  end

  # force http images to use https. If remote server cannot handle https a
  # broken image is expected. The `alt` keyword argument is required for
  # accessibility reasons and is a keyword argument instead of positional to
  # match the syntax of `image_tag` which this wraps.
  def force_https_image_tag(url, alt:)
    image_tag(force_https(url), alt: alt)
  end

  # force scheme of a url to https if it is currently http. if it is not http
  # just return the input with no changes
  def force_https(url)
    uri = URI(url)
    return url unless uri.scheme == 'http'
    uri.scheme = 'https'
    uri.to_s
  end
end
