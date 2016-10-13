module BentoHelper
  def box_enabled?(box)
    session[:boxes].include?(box)
  end

  def box_width
    (12 / session[:boxes].count).to_i
  end
end
