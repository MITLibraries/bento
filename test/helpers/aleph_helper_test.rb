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

  test 'aleph_source_record with MIT01 id' do
    assert_equal('https://library.mit.edu/item/123456789',
                 controller.aleph_source_record('MIT01123456789'))
  end

  test 'aleph_source_record with MIT30 id' do
    assert_equal('https://library.mit.edu/res/123456789',
                 controller.aleph_source_record('MIT30123456789'))
  end

  test 'aleph_source_record with bad id' do
    msg = assert_raises do
      controller.aleph_source_record('YO123456789')
    end
    assert_equal(
      'Invalid Aleph ID provided. Cannot construct URL to Aleph.',
      msg.message
    )
  end
end
