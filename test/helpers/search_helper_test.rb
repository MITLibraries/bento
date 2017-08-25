require 'test_helper'

include SearchHelper

class SearchHelperTest < ActionView::TestCase
  test 'guest?' do
    ActionDispatch::Request.any_instance.stubs(:remote_ip)
                           .returns('18.42.101.101')
    refute(controller.guest?)

    ActionDispatch::Request.any_instance.stubs(:remote_ip)
                           .returns('123.123.123.123')
    assert(controller.guest?)
  end

  test 'member?' do
    ActionDispatch::Request.any_instance.stubs(:remote_ip)
                           .returns('18.42.101.101')
    assert(controller.member?)

    ActionDispatch::Request.any_instance.stubs(:remote_ip)
                           .returns('123.123.123.123')
    refute(controller.member?)
  end
end
