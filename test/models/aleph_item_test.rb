require 'test_helper'

class AlephItemTest < ActiveSupport::TestCase
  test 'status_url' do
    assert_equal(
      AlephItem.new.status_url('MIT01001739356'),
      'https://fake_server.example.com/rest-dlf/record/MIT01001739356/'\
      'items?view=full&key=FAKE_KEY'
    )
  end

  test 'can return realtime status for an aleph id' do
    VCR.use_cassette('realtime aleph') do
      status = AlephItem.new.items('MIT01001739356')
      assert_equal(status[0][:status], 'In Library')
      assert_equal(status[0][:library], 'Hayden Library')
      assert_equal(status[0][:collection], 'Stacks')
      assert_equal(status[0][:call_number], 'PN1995.9.M86 M855 2010')
    end
  end
end
