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
