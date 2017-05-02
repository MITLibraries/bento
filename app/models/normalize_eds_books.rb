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
    result.get_it_label = 'Get it'
    result
  end

  def subjects
    return unless bibrecord.dig('BibEntity', 'Subjects')
    bibrecord['BibEntity']['Subjects']&.map do |s|
      [subject_name(s), subject_link(s)]
    end
  end

  def subject_name(subject)
    subject['SubjectFull']
  end

  def subject_link(subject)
    URI.encode_www_form_component("SU \"#{subject_name(subject)}\"")
  end

  def location
    copy(holdings)&.map { |l| [l['Sublocation'], l['ShelfLocator']] }
  end

  def publisher; end

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
