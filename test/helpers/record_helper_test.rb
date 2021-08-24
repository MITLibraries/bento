require 'test_helper'

include RecordHelper

class RecordHelperTest < ActionView::TestCase
  test 'force_https with http url changes to https' do
    assert_equal('https://example.com/yo', force_https('http://example.com/yo'))
  end

  test 'force_https with https url' do
    assert_equal('https://example.com/yo',
                 force_https('https://example.com/yo'))
  end

  test 'force_https with no scheme returns input unchanged' do
    assert_equal('example.com/yo', force_https('example.com/yo'))
  end
end
