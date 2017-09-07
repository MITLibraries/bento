require 'test_helper'

include AlephHelper

class AlephHelperTest < ActionView::TestCase
  test 'media?' do
    refute(controller.media?('POPCORN'))
    assert(controller.media?('DVD'))
  end

  test 'reserve?' do
    refute(controller.reserve?('POPCORN'))
    assert(controller.reserve?('Reserve Stacks'))
  end

  test 'archives?' do
    refute(controller.archives?('POPCORN'))
    assert(controller.archives?('Institute Archives'))
  end
end
