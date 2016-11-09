module BentoHelper
  def box_enabled?(box)
    session[:boxes].include?(box)
  end
end
