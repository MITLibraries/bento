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

  # Current request IP is outside our campus range
  def guest?
    if !Rails.env.production? && params[:guest].present?
      params[:guest] == 'true'
    else
      !member?
    end
  end

  # Current request IP is included in our campus range
  def member?
    mit_ips.include?(request.remote_ip)
  end

  def full_record_link(result)
    if Flipflop.enabled?(:local_full_record) && params[:target] != 'google'
      record_path(result.db_source.last, result.an)
    else
      result.url
    end
  end

  private

  # Source: http://kb.mit.edu/confluence/x/F4DCAg
  def mit_ips
    IPAddrRangeSet.new(
      '18.0.0.0/11'
    )
  end
end
