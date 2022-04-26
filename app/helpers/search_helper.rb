module SearchHelper
  def view_more_text
    case params[:target]
    when 'google'
      'website'
    when 'timdex'
      'archives and manuscripts'
    when ENV.fetch('PRIMO_BOOK_SCOPE')
      'books and media'
    when ENV.fetch('PRIMO_ARTICLE_SCOPE')
      'articles and chapters'
    end
  end

  def full_record_link(result)
    result.dedup_url || result.url
  end
end
