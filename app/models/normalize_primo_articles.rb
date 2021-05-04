# Tranforms results from {SearchPrimo} into normalized {Result}s
# for metadata that is relevant for article type results
class NormalizePrimoArticles
  def initialize(record)
    @record = record
  end

  def article_metadata(result)
    result.citation = numbering
    result.in = journal_title
    result
  end

  def journal_title
    return unless @record['pnx']['addata']['jtitle']
    @record['pnx']['addata']['jtitle'].join('')
  end

  def numbering
    return unless @record['pnx']['addata']['volume']
    if @record['pnx']['addata']['issue'].present?
      "volume #{@record['pnx']['addata']['volume'].join('')} issue #{@record['pnx']['addata']['issue'].join('')}"
    else
      "volume #{@record['pnx']['addata']['volume'].join('')}"
    end 
  end
end
