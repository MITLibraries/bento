# Tranforms results from {SearchEds} into normalized {Result}s
# for metadata that is relevant for book type results
class NormalizeEdsBooks
  def initialize(record)
    @record = record
  end

  def book_metadata(result)
    result.thumbnail = thumbnail
    result.publisher = publisher
    result.location = location
    result.subjects = subjects
    result
  end

  def subjects
    bibrecord['BibEntity']['Subjects']&.map do |s|
      [s['SubjectFull'], subject_link(s['SubjectFull'])]
    end
  end

  def subject_link(subject)
    ENV['EDS_ALEPH_URI'] + URI.encode_www_form_component("DE \"#{subject}\"")
  end

  def location
    copy(holdings)&.map { |l| [l['Sublocation'], l['ShelfLocator']] }
  end

  def publisher
  end

  def thumbnail
    return unless @record['ImageInfo']
    @record['ImageInfo'].select { |i| i['Size'] == 'thumb' }&.first['Target']
  end

  private

  def holdings
    @record['Holdings']&.map { |h| h['HoldingSimple'] }
  end

  def copy(holdings)
    holdings&.map { |c| c['CopyInformationList'] }&.flatten
  end

  def bibrecord
    @record.dig('RecordInfo', 'BibRecord')
  end
end
