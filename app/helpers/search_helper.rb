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
    if Flipflop.enabled?(:local_full_record) && params[:target] != 'google' && params[:target] != 'timdex'
      record_path(result.db_source.last, result.an)
    else
      result.url
    end
  end

  private

  # Source: http://kb.mit.edu/confluence/x/F4DCAg
  def mit_ips
    IPAddrRangeSet.new(
      '18.0.0.0/9',
      '18.128.0.0/15',
      '18.131.0.0/16',
      '18.132.0.0/14',
      '18.137.0.0/16',
      '18.138.0.0/15',
      '18.140.0.0/14',
      '18.146.0.0/16',
      '18.149.0.0/16',
      '18.150.0.0/16',
      '18.152.0.0/16',
      '18.154.0.0/15',
      '18.156.0.0/14',
      '18.161.0.0/16',
      '18.163.0.0/16',
      '18.165.0.0/16',
      '18.166.0.0/15',
      '18.168.0.0/14',
      '18.172.0.0/15',
      '18.174.0.0/16',
      '18.176.0.0/15',
      '18.178.0.0/16',
      '18.180.0.0/15',
      '18.183.0.0/16',
      '18.186.0.0/15',
      '18.189.0.0/16',
      '18.190.0.0/16',
      '18.192.0.0/15',
      '18.198.0.0/15',
      '18.229.0.0/16',
      '18.230.0.0/16',
      '18.238.0.0/15',
      '18.240.0.0/14',
      '18.244.0.0/15',
      '18.247.0.0/16',
      '18.248.0.0/16',
      '18.250.0.0/15',
      '18.252.0.0/16',
      '18.254.0.0/15'
    )
  end
end
