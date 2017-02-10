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
    items
  end

  def process_item(item)
    { library: item.xpath('z30/z30-sub-library').text,
      collection: item.xpath('z30/z30-collection').text,
      status: item.xpath('status').text,
      call_number: item.xpath('z30/z30-call-no').text }
  end

  def status_url(id)
    [ENV['ALEPH_API_URI'], 'record/', id, '/items?view=full&key=',
     ENV['ALEPH_KEY']].join('')
  end

  def xml_status(id)
    Nokogiri::XML(open(status_url(id)))
  end
end
