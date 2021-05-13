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

  def openurl
    return unless @record['delivery']['almaOpenurl']
    @record['delivery']['almaOpenurl']
  end
end
