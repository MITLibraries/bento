module SearchHelper
  def view_more_text
    if params[:target] == 'google'
      'website'
    elsif params[:target] == 'timdex'
      'archives and manuscripts'
    elsif params[:target] == ENV.fetch('PRIMO_BOOK_SCOPE')
      'books and media'
    elsif params[:target] == ENV.fetch('PRIMO_ARTICLE_SCOPE')
      'articles and chapters'
    end
  end

  def full_record_link(result)
    result.dedup_url || result.url
  end
end
