module LoginHelper
  # Authentication Flow and Guest Mode documentation is available
  # https://mitlibraries.atlassian.net/wiki/x/CoAeAw
  def login_url
    if !Rails.env.production?
      request.original_url + '?guest=false'
    else
      ENV['PROXY_PREFIX'] + request.original_url
    end
  end
end
