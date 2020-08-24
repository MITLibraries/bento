# Creates a Button with an actionable URL for items that can be either put on
# Hold or Recalled. Either one or zero of these options if ever valid (never
# both). (i.e. it's okay if an item can't be held or recalled, but it is never
# okay for an item to both holdable and recallabe).
class ButtonHoldRecall
  include ButtonMaker

  def html_button
    if worldcatinate?
      "<a class='btn button-secondary button-small' " \
      "href='https://worldcatinator.mit.edu/?bibid=#{@doc_number}'>Request non-MIT copy (3-4 days)</a>"
    elsif eligible_recall?
      "<a class='btn button-subtle button-small' " \
        "href='#{url}'>Recall (7+ days)</a>"
    elsif eligible_hold?
      "<a class='btn button-secondary button-small' " \
          "href='#{url}'>Place hold (1-2 days)</a>"
    end
  end


  def worldcatinate?
    return false if Flipflop.enabled?(:disable_worldcatinate)
    true if @library == 'Unavailable due to renovation'
  end

  def eligible_hold?
    return false if @on_reserve || @library == 'Physics Dept. Reading Room'
    return false if Flipflop.enabled?(:disable_holds)
    available_here_now? && hold_recallable?
  end

  def eligible_recall?
    return false if Flipflop.enabled?(:disable_recalls)
    return unless recallable_status?
    return false if @on_reserve || @library == 'Physics Dept. Reading Room'
    !eligible_hold? && hold_recallable?
  end

  def url
    queryarray = { func: 'item-hold-request',
                   doc_library: 'MIT50',
                   adm_doc_number: @doc_number,
                   item_sequence: @item_sequence }

    url = URI::HTTP.build(host: 'library.mit.edu',
                          path: '/F',
                          query: queryarray.to_query)
    url.to_s
  end

  # Items with these process & item statuses may be put on hold/recalled.
  def hold_recallable?
    return false if @on_reserve || @library == 'Physics Dept. Reading Room'
    [
      # Items with these status codes may be requested from any library,
      # except the Annex.
      %w[01 03 05 12 19 21].include?(@z30status_code) &&
        @library != 'Library Storage Annex',

      # Items with status code 23 may be requested from only some libraries.
      @z30status_code == '23' && ['Barker Library',
                                  'Dewey Library',
                                  'Hayden Library',
                                  'Rotch Library',
                                  'Library Storage Annex'].include?(@library),

      # The Annex is special.
      %w[13 14 15 56 57].include?(@z30status_code) &&
        @library == 'Library Storage Annex'
    ].any?
  end

  # It's not enough to say `@status != 'In Library'`, because the item might
  # have a status of 'On Order' or 'Missing', and those are not recallable.
  # We have to actually enumerate recallable statuses. Note that we aren't
  # sure what all of these mean or if we even still use them, but this is how
  # Aleph is configured, so we're matching it.
  def recallable_status?
    [
      @status.start_with?('Due'),
      @status.start_with?('In Transit'),
      recallable_statuses.include?(@status)
    ].any?
  end

  def recallable_statuses
    ['Recalled', 'On Hold', 'Requested', 'Expected at $1',
     'Reshelving', 'Long Overdue', 'Claimed Returned']
  end
end
