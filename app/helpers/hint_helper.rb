module HintHelper
  # generates a link with appropriate data type for our analytics
  def hint_link(link_text)
    link_to(link_text, @hint.url, data: { type: data_type })
  end

  # display a user friendly distinction between Hint sources
  def display_type
    if @hint.source == 'custom'
      'Popular result'
    else
      'Were you looking for...'
    end
  end

  # Allows analytics tracking to distinguish clicked Hint sources
  def data_type
    "Hint_#{@hint.source}"
  end
end
