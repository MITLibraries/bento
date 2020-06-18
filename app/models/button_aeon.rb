# Creates a Button with an actionable URL for items that allow reqeusts via Aeon
# Business logic documented in external wiki:
# https://mitlibraries.atlassian.net/wiki/spaces/AIP/pages/989560879/Aeon+Request+Buttons+in+Barton
class ButtonAeon
  include ButtonMaker

  def construct_aeon_link
    'https://sfx.mit.edu/sfx_local?' +
    {
      pid: ["DocNumber=#{@doc_number}", "Ip=library.mit.edu", "Port=9909"].join(","),
      barcode: @barcode,
      sid: 'ALEPH:AEON',
      form: '30',
      action: '10',
      'rft.genre': ref_genre,
      'sfx.skip_augmentation': '1'
    }.to_query
  end

  def link_text
    if @aeon_type == 'onsite'
      'Request for on-site use'
    else
      'Order a copy'
    end
  end

  def ref_genre
    if @aeon_type == 'onsite'
      'book'
    else
      'copy'
    end
  end

  def html_button
    return unless eligible?
    "<a class='btn button-secondary button-small' href=#{construct_aeon_link}>#{link_text}</a>"
  end

  def eligible?
    return true if @library == 'Institute Archives'
    return true if (@library == 'Rotch Library' && @collection == 'Limited Access Collection')
    return false 
  end
end
