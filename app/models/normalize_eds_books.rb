# Tranforms results from {SearchEds} into normalized {Result}s
#
class NormalizeEdsBooks
  def initialize(record)
    @record = record
  end

  def subjects(record)
    bibrecord(record)['BibEntity']['Subjects']&.map { |s| s['SubjectFull'] }
  end

  def location(record)
    copy(holdings(record))&.map { |l| [l['Sublocation'], l['ShelfLocator']] }
  end

  def holdings(record)
    record['Holdings']&.map { |h| h['HoldingSimple'] }
  end

  def copy(holdings)
    holdings&.map { |c| c['CopyInformationList'] }&.flatten
  end

  def publisher(record)
  end

  def thumbnail(record)
    return unless record['ImageInfo']
    record['ImageInfo'].select { |i| i['Size'] == 'thumb' }&.first['Target']
  end

  def bibrecord(record)
    record.dig('RecordInfo', 'BibRecord')
  end
end
