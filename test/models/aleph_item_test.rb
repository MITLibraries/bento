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
      assert_equal('In Library', status[0][:status])
      assert_equal('Hayden Library', status[0][:library])
      assert_equal('Stacks', status[0][:collection])
      assert_equal('PN1995.9.M86 M855 2010', status[0][:call_number])
      assert_equal(true, status[0][:available?])
      assert_equal('Available', status[0][:label])
    end
  end

  test 'can identify non available items' do
    VCR.use_cassette('realtime aleph unavailable') do
      status = AlephItem.new.items('MIT01002511337')
      assert_equal('03/02/2017 11:59 PM', status[0][:status])
      assert_equal('Rotch Library', status[0][:library])
      assert_equal('Service Desk', status[0][:collection])
      assert_equal('QA27.5.L44 2016a', status[0][:call_number])
      assert_equal(false, status[0][:available?])
      assert_equal('Not available at MIT', status[0][:label])
    end
  end
end
