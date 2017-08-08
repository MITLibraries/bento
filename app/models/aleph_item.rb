# Checks Aleph for Realtime Status of Items
#
# == Required Environment Variables:
# - ALEPH_API_URI
# - ALEPH_KEY
#
# == Note
# - This interacts with an Aleph API Middleware and not directly with the
# Aleph API because Aleph natively only supports IP restriction which was
# not acceptable for this application's cloud based deployment intent
require 'open-uri'
class AlephItem
  # ex: https://walter.mit.edu/rest-dlf/record/MIT01000293592/items?view=full&key=SECRETKEY
  def items(id)
    items = []
    xml_status(id).xpath('//items').children.each do |item|
      items << process_item(item)
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

  def process_item(item)
    { library: item.xpath('z30/z30-sub-library').text,
      collection: item.xpath('z30/z30-collection').text,
      status: status(item),
      call_number: item.xpath('z30/z30-call-no').text,
      available?: available?(item),
      label: label(item),
      description: item.xpath('z30/z30-description').text }
  end

  def status(item)
    item.xpath('status').text
  end

  def available_statii
    ['In Library', 'New Books Displ', 'MIT Reads', 'Received',
     'LSA Use Only', 'On Display', 'Room Use Only', 'See Note Above',
     'Archives Reading Room Use Only']
  end

  def available?(item)
    available_statii.include?(status(item))
  end

  def label(item)
    if available?(item)
      'Available'
    else
      'Not available at MIT'
    end
  end

  def status_url(id)
    [ENV['ALEPH_API_URI'], 'record/', id, '/items?view=full&key=',
     ENV['ALEPH_KEY']].join('')
  end

  def xml_status(id)
    Nokogiri::XML(open(status_url(id)))
  end
end
