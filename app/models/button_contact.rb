# Creates a Button with an actionable URL for items that require contacting
# a library for more information.
class ButtonContact
  include ButtonMaker

  def html_button
    return unless eligible?
    "<a class='btn button-secondary button-small' " \
      "href='https://libraries.mit.edu/archives/'>Contact Us</a>"
  end

  def eligible?
    @library == 'Institute Archives'
  end
end
