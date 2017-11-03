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
require 'open-uri'
class AlephItem
  # ex: https://walter.mit.edu/rest-dlf/record/MIT01000293592/items?view=full&key=SECRETKEY
  def items(id, oclc)
    items = []
    xml_status(id).xpath('//items').children.each do |item|
      items << process_item(item, oclc)
    end
    custom_sort(items)
  end

  # Sorts by `library` and numbers contained within the `description`.
  # We need to sort on multiple fields to ensure items from multiple libraries
  # are sorted within the library and not as a whole. Naive sorting of strings
  # will cause an order such as v.1 v.10 v.2. This sorts by the numbers in the
  # description to provde a human expected sort order.
  def custom_sort(items)
    items.sort do |a, b|
      [a[:library], a[:description][/\d+/].to_i] <=>
        [b[:library], b[:description][/\d+/].to_i]
    end
  end

  def process_item(item, oclc)
    { library: library(item),
      collection: item.xpath('z30/z30-collection').text,
      call_number: item.xpath('z30/z30-call-no').text,
      available?: available?(item),
      label: label(item),
      description: description(item),
      buttons: ButtonMaker.new(item, oclc).all_buttons }
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~ Properties of Aleph items ~~~~~~~~~~~~~~~~~~~~~~~~
  def available?(item)
    available_statuses.include?(status(item))
  end

  def available_statuses
    ['In Library', 'New Books Displ', 'MIT Reads', 'Received',
     'LSA Use Only', 'On Display', 'Room Use Only', 'See Note Above',
     'Archives Reading Room Use Only']
  end

  def description(item)
    item.xpath('z30/z30-description').text
  end

  def label(item)
    if available?(item)
      'Available'
    else
      'Checked out'
    end
  end

  def library(item)
    item.xpath('z30/z30-sub-library').text
  end

  def status(item)
    item.xpath('status').text
  end

  def status_url(id)
    [ENV['ALEPH_API_URI'], 'record/', id, '/items?view=full&key=',
     ENV['ALEPH_KEY']].join('')
  end

  def xml_status(id)
    Nokogiri::XML(open(status_url(id)))
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
