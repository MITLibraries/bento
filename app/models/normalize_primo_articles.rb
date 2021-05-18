# Tranforms results from {SearchPrimo} into normalized {Result}s
# for metadata that is relevant for article type results
class NormalizePrimoArticles
  def initialize(record)
    @record = record
  end

  def article_metadata(result)
    result.citation = numbering || chapter_numbering
    result.in = journal_title || book_title
    result.openurl = openurl
    result
  end

  def journal_title
    return unless @record['pnx']['addata']['jtitle']
    @record['pnx']['addata']['jtitle'].join('')
  end

  def book_title
    return unless @record['pnx']['addata']['btitle']
    @record['pnx']['addata']['btitle'].join('')
  end

  def numbering
    return unless @record['pnx']['addata']['volume']
    if @record['pnx']['addata']['issue'].present?
      "volume #{@record['pnx']['addata']['volume'].join('')} issue #{@record['pnx']['addata']['issue'].join('')}"
    else
      "volume #{@record['pnx']['addata']['volume'].join('')}"
    end 
  end

  def chapter_numbering
    return unless @record['pnx']['addata']['btitle']
    return unless @record['pnx']['addata']['date'] && @record['pnx']['addata']['pages']
    "#{@record['pnx']['addata']['date'].join('')}, pp. #{@record['pnx']['addata']['pages'].join('')}"
  end

  # Here we are converting the Alma link resolver URL provided by the Primo 
  # Search API to redirect to the Primo UI. This is done for UX purposes, 
  # as the regular Alma link resolver URLs redirect to a plaintext 
  # disambiguation page.
  def openurl
    return unless @record['delivery']['almaOpenurl']
    primo_openurl = ['https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=',
                     ENV['EXL_INST_ID'], '&vid=', ENV['PRIMO_VID'],'&'].join('')
    link_resolver_url = @record['delivery']['almaOpenurl'].gsub('https://na06.alma.exlibrisgroup.com/view/uresolver/01MIT_INST/openurl?',
                                                                primo_openurl)
    [link_resolver_url, '&u.ignore_date_coverage=true'].join('')
  end
end
