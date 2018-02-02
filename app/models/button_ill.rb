class ButtonIll
  include ButtonMaker

  def html_button
    return unless eligible?
    # It's possible to get this far but not be able to construct a valid ILL
    # URL. This happens if the item is on order but we don't yet know its OCLC
    # number.
    return unless url
    "<a class='btn button-secondary button-small' "\
      "href='#{url}'>Request non-MIT copy (3-4 days)</a>"
  end

  # Can you request that this item be ordered via ILL?
  # Items must have an OCLC number to be ILLable. Items that are in the library
  # now and can simply be borrowed, with reasonable loan terms, may not be
  # ILLed. (Items that are in the library but have extremely short-term loan
  # periods, such as two hours, are eligible for ILL in case patrons need them
  # for a while. Those statuses are deliberately excluded from the `none?`
  # status checker.
  # Items eligible this way may ultimately be ordered via either BorrowDirect
  # or ILLiad. We prefer that patrons use BorrowDirect; WorldCat will send them
  # there preferentially if it is an option.
  def eligible?
    # If it has a disqualifying status, you can't ILL it. If it doesn't, you're
    # good to go.
    [
      available_here_now?,
      @status == 'Received',
      ineligible_statuses.include?(@z30status)
    ].none?
  end

  def url
    return unless @oclc_number.present?
    "https://mit.worldcat.org/search?q=no%3A#{@oclc_number}"
  end

  # These z30 statuses are never allowed to request via ILL
  def ineligible_statuses
    ['1 Day Loan',
     '1 Week No Renew',
     '1 Week No Renew Equip',
     '2 Day Loan',
     '24 Hour Loan',
     '3 Day Loan',
     'Audio Recorder',
     'Due at Closing',
     'Journal Loan',
     'Music CD/DVD',
     'Pass',
     'See Note Above',
     'Two Week Loan']
  end
end
