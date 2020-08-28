# Checks Aleph for Realtime Status of Items
#
# == Required Environment Variables:
# - ALEPH_API_URI
# - ALEPH_KEY
#
# == Note
# - This interacts with an Aleph API Middleware and not directly with the
# Aleph API because Aleph natively only supports IP restriction which was
# not acceptable for this application's cloud based deployment intent.
# - The class is in need of a refactor which we are intentionally not doing at
# this time; see bottom of file for details.
# - We pass in `oclc` and `scan` not because we love it, but because it saves
# us from making two API calls to Aleph instead of one. This is a case of
# efficiency winning out over a preferred application design.
# - `scan` is set via `record_helper.rb`. You are welcome.
require 'open-uri'
class AlephItem
  include ProcessingLabeler

  # ex: https://walter.mit.edu/rest-dlf/record/MIT01000293592/items?view=full&key=SECRETKEY
  def items(id, oclc, scan)
    items = []
    # This used to say .xpath('//items').children.each. However, the Aleph API
    # returns at most 990 items; if there are more, there is a <partial>
    # element also included in <items>. Our attempts to parse useful data out
    # of <partial> will fail, leading to a bogus item in the availability
    # section of the view which is checked out but has no metadata.
    xml_status(id).xpath('//items/item').each do |item|
      items << process_item(item, oclc, scan)
    end
    custom_sort(items)
  end

  # Sorts by `library` and numbers contained within the `description`.
  # We need to sort on multiple fields to ensure items from multiple libraries
  # are sorted within the library and not as a whole. Naive sorting of strings
  # will cause an order such as v.1 v.10 v.2. This sorts by the numbers in the
  # description to provde a human expected sort order.
  # This sorts *first* by call number and *next* by library; this makes it
  # easier for people to look through large journal holdings.
  # Note that it swaps b <=>a for description but a<=>b for library. This lets
  # us display dates/volumes in DESCENDING order (on the theory that people are
  # most likely looking for more recent holdings), but libraries in ASCENDING
  # order (since this is how humans expect alphabetization to work).
  def custom_sort(items)
    items.sort do |a, b|
      [b[:description][/\d+/].to_i, a[:library]] <=>
        [a[:description][/\d+/].to_i, b[:library]]
    end
  end

  def process_item(item, oclc, scan)
    { library: library(item),
      collection: collection(item),
      call_number: item.xpath('z30/z30-call-no').text,
      available?: available?(item),
      label: label(item),
      description: description(item),
      buttons: all_buttons(item, oclc, scan) }
  end

  # Defines the buttons and button order that may display. Each button has
  # logic that determines whether it will output HTML or not, so all we need to
  # do here is call the #html_button method of each button we are interested in
  # and the button will take care of the rest.
  def all_buttons(item, oclc, scan)
    [ButtonHoldRecall.new(item, oclc, scan).html_button,
     ButtonIll.new(item, oclc, scan).html_button,
     ButtonScan.new(item, oclc, scan).html_button,
     ButtonAeon.new(item, oclc, scan, "onsite").html_button,
     ButtonAeon.new(item, oclc, scan, "copy").html_button,
     ButtonRequestDigital.new(item, oclc, scan).html_button]
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~ Properties of Aleph items ~~~~~~~~~~~~~~~~~~~~~~~~
  def available?(item)
    return false if library(item) == 'Unavailable due to renovation'
    available_statuses.include?(status(item))
  end

  def available_statuses
    ['In Library', 'New Books Displ', 'MIT Reads', 'Received',
     'LSA Use Only', 'On Display', 'Room Use Only', 'See Note Above',
     'Archives Reading Room Use Only']
  end

  def collection(item)
    item.xpath('z30/z30-collection').text
  end

  def description(item)
    item.xpath('z30/z30-description').text
  end

  # This will return something like "Available - $status" if the status is
  # meaningful, or just "Available" if it isn't.
  # The processing_label is provided by ProcessingLabeler; there's some work
  # to be done in assuring data quality, so we encapsulate it there.
  def label(item)
    [base_label(item),
      processing_label(status(item), z30_item_process(item), reserve?(item))
    ].compact.join(' - ')
  end

  def base_label(item)
    if available?(item) && library(item) != 'Unavailable due to renovation'
      'Available'
    else
      'Not available'
    end
  end

  def library(item)
    item.xpath('z30/z30-sub-library').text
  end

  def reserve?(item)
    collection(item) == 'Reserve Stacks'
  end

  def status(item)
    if library(item) == 'Unavailable due to renovation'
      'Local copy unavailable'
    else
      item.xpath('status').text
    end
  end

  def status_url(id)
    [ENV['ALEPH_API_URI'], 'record/', id, '/items?view=full&key=',
     ENV['ALEPH_KEY']].join('')
  end

  def xml_status(id)
    Nokogiri::XML(open(status_url(id)))
  end

  def z30_item_process(item)
    item.xpath('z30-item-process-status-code').text
  end
end

# A note about refactoring:
#
# The AlephItem class should actually be two classes:
#   * AlephResponse
#     * Processes XML from the Aleph API
#     * May represent one or more actual library objects
#     * Has a function which returns an array of AlephObjects in lieu of the
#       current `items` function
#   * AlephObject
#     * Is instantiated by AlephResponse with data extracted from XML
#     * Represents exactly one library object
#     * Contains all the methods that currently take `item` as an argument -
#       those actually want to be methods of an AlephItem class and in many
#       cases want to be setting or using instance variables (e.g. `@title`)
#
# Originally this class was only needed for AlephResponse-type things; it grew
# a lot of AlephObject-type things to support the needs of the full record view.
#
# We discussed refactoring it at this time but chose not to because:
# 1) We believe we are nearing the end of our need to consume data from Aleph,
#    so the awkward developer UI will not slow us down as much as the refactor
#    would;
# 2) We may be moving to a new ILS in the near-ish term, which would render a
#    refactor moot.
#
# If we find ourselves needing to do substantial new work with this class after
# the close of DI-513, we may wish to reconsider the decision not to refactor.
#
# If we do refactor it will have implications for the following:
# * AlephItem tests
#   * Will need to be renamed and separated out into AlephResponse and
#     AlephObject tests
# * AlephHelper
#   * Some of its responsibiilities may more properly be methods on AlephObject
# * views/aleph/full_item_status.html.erb
#   * This file expects items to be key/value hashes; it will need to expect
#     instead to get AlephObjects and access their instance variables or methods
