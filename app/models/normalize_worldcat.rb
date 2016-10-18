# Tranforms results from {SearchWorldcat} into normalized {Result}s
#
class NormalizeWorldcat
  # Translate Google results into local result model
  def to_result(results)
    norm = {}
    xml = Nokogiri::XML.parse(results.body)
    norm['total'] = xml.xpath('//xmlns:numberOfRecords').text.to_i
    norm['results'] = []
    extract_results(xml, norm)
    norm
  end

  private

  # Extract the information we care about from the raw results and add them
  # return them as an array of {result}s
  def extract_results(xml, norm)
    xml.xpath('//xmlns:oclcdcs').each do |item|
      result = Result.new(item.xpath('dc:title').text.strip,
                          item.xpath('dc:date').text.strip,
                          url(item),
                          'worldcat')
      result.authors = authors(item)
      norm['results'] << result
    end
  end

  # Assemble authors array
  def authors(item)
    authors = []
    item.xpath('dc:creator|dc:contributor').each do |creator|
      authors << creator.text.strip
    end
    authors
  end

  # Assemble a link to a record
  def url(item)
    'http://www.worldcat.org/oclc/' + \
      item.xpath('oclcterms:recordIdentifier[not(@xsi:type)]').text.strip
  end
end
