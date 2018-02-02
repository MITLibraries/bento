
# Given an item, the ButtonMaker does the following:
# * checks its eligibility for all actions
# * when eligible, creates the HTML for a button powering that action
# all_buttons returns the list of buttons thus created.
# This means that we don't have to do any complex logic in the HTML - we can
# just iterate through all available buttons and display them.
# Important features:
# @options is a list of the names of each action that might be available for an
# item.
# For each action in options, the following functions must exist:
# * eligible_for_#{action}? - returns true/false
# * make_button_for_#{action} - returns HTML of relevant button
# This should probably have related to the Great Not-Completed AlephObject
# Refactor, but it just got too janky to deal with all the edge cases in our
# circ logic - too hard to tell whether they'd all been dealt with, except by
# pulling it all into a special-purpose, encapsulated place.
# You probably don't want to, but when all else fails familiarize yourself with:
# https://mitlibraries.atlassian.net/wiki/spaces/DI/pages/58654721/ButtonMaker+documentation
module ButtonMaker
  def initialize(item, oclc, scan)
    @item = item
    @oclc = oclc
    @scan = scan
    set_item_properties
  end

  def set_item_properties
    @barcode = @item.xpath('z30/z30-barcode').text
    @call_number = @item.xpath('z30/z30-call-no').text
    @collection = @item.xpath('z30/z30-collection').text
    @doc_number = @item.xpath('z30/z30-doc-number').text
    @identifier = clean_identifier # May be ISBN or ISSN
    @item_sequence = @item.xpath('z30/z30-item-sequence').text
    @library = @item.xpath('z30/z30-sub-library').text
    @oclc_number = clean_oclc
    @on_reserve = (@collection == 'Reserve Stacks')
    @status = @item.xpath('status').text
    @title = @item.xpath('z13/z13-title').text
    @z30status = @item.xpath('z30/z30-item-status').text
    # Yes, this excludes `z30/` on purpose.
    @z30status_code = @item.xpath('z30-item-status-code').text
    @year = @item.xpath('z13/z13-year').text
    @volume = @item.xpath('z30/z30-description').text
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Misc utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # This is used for both Hold/Recall and ILL purposes.
  # We won't generally ILL or Recall items that fit these criteria as we want
  # them to be placed on hold if possible.
  def available_here_now?
    # You can request things that are in the library and have reasonable
    # loan policies.
    [
      'In Library', 'MIT Reads', 'New Books Displ', 'On Display'
    ].include?(@status)
  end

  def clean_oclc
    return unless @oclc.present?
    # @record.eds_document_oclc may return a list of OCLC numbers as encoded
    # HTML (e.g. `13978097&lt;br /&gt;42378644` as the OCLC for
    # `/record/cat00916a/mit.000879736`). We're just going to take the first
    # one and hope for the best.
    # If there is no match, this will return an empty string.
    /[0-9]*/.match(@oclc)[0]
  end

  def clean_identifier
    # The isbn_issn field may contain either an ISBN or an ISSN. Furthermore,
    # it may contain junk data. (For example: `0826213391 (v. 1 : alk. paper)`
    # was seen in the wild.) This function finds the first object which is
    # either an ISBN or an ISSN.
    identifier_text = @item.xpath('z13/z13-isbn-issn').text
    isbn_regex = /(?=[0-9X]{10}|(?=(?:[0-9]+[- ]){3})[- 0-9X]{13}|97[89][0-9]{10}|(?=(?:[0-9]+[- ]){4})[- 0-9]{17}$)(?:97[89][- ]?)?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]/
    issn_regex = /[0-9]{4}-[0-9]{3}[0-9X]/
    isbn_match = isbn_regex.match(identifier_text)
    issn_match = issn_regex.match(identifier_text)

    # This statement will assign to `identifier`, in this order of priority:
    # 1) the first plausible ISBN found; 2) the first plausible ISSN found;
    # 3) false.
    identifier = (isbn_match && isbn_match[0]) || (issn_match && issn_match[0])
    identifier || nil
  end
end
