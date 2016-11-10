# Tranforms results from {SearchEds} into normalized {Result}s
#
class NormalizeEdsBooks
  def initialize(record)
    @record = record
  end

  def subjects(record)
    bibrecord(record)['BibEntity']['Subjects']&.map do |s|
      [s['SubjectFull'], subject_link(s['SubjectFull'])]
    end
  end

  def subject_link(subject)
    ENV['EDS_ALEPH_URI'] + URI.encode_www_form_component("DE \"#{subject}\"")
  end

  def location(record)
    copy(holdings(record))&.map { |l| [l['Sublocation'], l['ShelfLocator']] }
  end

  def publisher(record)
  end

  def thumbnail(record)
    return unless record['ImageInfo']
    record['ImageInfo'].select { |i| i['Size'] == 'thumb' }&.first['Target']
  end

  private

  def holdings(record)
    record['Holdings']&.map { |h| h['HoldingSimple'] }
  end

  def copy(holdings)
    holdings&.map { |c| c['CopyInformationList'] }&.flatten
  end

  def bibrecord(record)
    record.dig('RecordInfo', 'BibRecord')
  end
end
