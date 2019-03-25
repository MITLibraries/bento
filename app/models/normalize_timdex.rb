# Tranforms results from TIMDEX into normalized {Result}s
#
class NormalizeTimdex
  # Translate Timdex results into local result model
  def to_result(results, q)
    norm = {}
    norm['total'] = results['hits'].to_i
    norm['results'] = []
    norm['eds_ui_view_more'] = view_more(q)
    extract_results(results, norm)

    norm
  end

  private

  def view_more(q)
    ''
  end

  # Extract the information we care about from the raw results and add them
  # return them as an array of {result}s
  def extract_results(results, norm)
    return unless results['records']

    counter = 0
    results['records'].each do |item|
      break if counter >= 5

      result = Result.new(item.title, item.source_link)
      result.authors = ugh_authors(item.authors) if item.authors
      result.year = item.publication_date
      result.db_source = 'timdex'
      result.an = "MIT01#{item.id}"
      result.id = item.id
      # result.uniform_title = 'uniform title'
      result.type = item.content_type

      result.location = item.locations
      result.subjects = ugh_subjects(item.subjects) if item.subjects

      norm['results'] << result
      counter += 1
    end
  end

  # We currently have an array of author name, search jump start we need to
  # replicate here for our views to remain stable. It may be better to rip this
  # apart into seprate views. We'll see.
  def ugh_authors(authors)
    authors.map { |a| [a, a] }
  end

  def ugh_subjects(subjects)
    subjects.map { |s| [s, s] }
  end
end
