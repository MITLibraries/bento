module SearchHelper
  def view_more_text
    if params[:target] == 'books'
      'books and media'
    elsif params[:target] == 'articles'
      'articles and journals'
    elsif params[:target] == 'google'
      'website'
    end
  end
end
