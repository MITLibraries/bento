require 'test_helper'

class RecordControllerTest < ActionDispatch::IntegrationTest
  test 'should get record' do
    VCR.use_cassette('record: bananas', allow_playback_repeats: true) do
      get record_url('cat00916a', 'mit.001492509')
      assert_response :success
    end
  end

  test 'should handle missing parameters' do
    get record_url('dog00916a')
    assert_response :redirect
  end

  test 'should handle invalid parameters' do
    VCR.use_cassette('record: no such database',
                     allow_playback_repeats: true) do
      get record_url('dog00916a', 'mit.001492509')
      assert_includes(@response.body, 'The requested record was not found.')
    end
  end

  test 'recover from bad EDS response' do
    VCR.use_cassette('record: broken session',
                     allow_playback_repeats: true) do
      get record_url('dog00916a', 'mit.001492509')
      assert_includes(@response.body,
                      'An error occurred accessing this record')
    end
  end

  test 'clean_keywords' do
    VCR.use_cassette('record: article', allow_playback_repeats: true) do
      get record_url('aci', '123877356')

      assert_equal(
        ['Carbon Nanotube Biosensors', 'Field Effect Transistors', 'IL6'],
        @controller.instance_variable_get(:@keywords)
      )
    end
  end

  test 'direct_link' do
    VCR.use_cassette('record: direct', allow_playback_repeats: true) do
      ActionDispatch::Request.any_instance.stubs(:remote_ip).returns('18.0.0.0')
      get record_direct_link_url('mdc', '25750248')
      assert_response :redirect
      assert_redirected_to('http://example.com/redirectomundo')
    end
  end

  test 'direct_link with invalid record' do
    VCR.use_cassette('record: direct invalid', allow_playback_repeats: true) do
      ActionDispatch::Request.any_instance.stubs(:remote_ip).returns('18.0.0.0')
      get record_direct_link_url('dog00916a', 'mit.001492509')
      assert_includes(@response.body, 'The requested record was not found.')
    end
  end

  test 'record not found' do
    VCR.use_cassette('record: not found', allow_playback_repeats: true) do
      ActionDispatch::Request.any_instance.stubs(:remote_ip).returns('18.0.0.0')
      get record_direct_link_url('cat00916a', 'mit.003696445')
      assert_includes(@response.body, 'The requested record was not found.')
    end
  end

  test 'direct_link as guest' do
    get record_direct_link_url('cat00916a', 'mit.001492509')
    follow_redirect!
    assert_includes(@response.body, 'Restricted access.')
  end

  test 'direct_link with invalid record as a guest' do
    get record_direct_link_url('dog00916a', 'mit.001492509')
    follow_redirect!
    assert_includes(@response.body, 'Restricted access.')
  end

  test 'cache_path for guests' do
    VCR.use_cassette('record: bananas', allow_playback_repeats: true) do
      get record_url('cat00916a', 'mit.001492509')
      assert_equal(@controller.send(:cache_path),
                   'http://www.example.com/record/cat00916a/mit.001492509?guest=true&pride=false&source=cat00916a')
      assert_response :success
    end
  end

  test 'cache_path for non-guests' do
    VCR.use_cassette('record: bananas nonguest',
                     allow_playback_repeats: true) do
      ActionDispatch::Request.any_instance.stubs(:remote_ip)
                             .returns('18.10.101.101')
      get record_url('cat00916a', 'mit.001492509')
      assert_equal(@controller.send(:cache_path),
                   'http://www.example.com/record/cat00916a/mit.001492509?guest=false&pride=false&source=cat00916a')
      assert_response :success
    end
  end

  test 'cache_path for pride disabled' do
    VCR.use_cassette('record: bananas', allow_playback_repeats: true) do
      get record_url('cat00916a', 'mit.001492509')
      assert_equal(@controller.send(:cache_path),
                   'http://www.example.com/record/cat00916a/mit.001492509?guest=true&pride=false&source=cat00916a')
      assert_response :success
    end
  end

  test 'cache_path for pride enabled' do
    Flipflop.stub(:enabled?, true) do
      VCR.use_cassette('record: bananas', allow_playback_repeats: true) do
        get record_url('cat00916a', 'mit.001492509')
        assert_equal(@controller.send(:cache_path),
                     'http://www.example.com/record/cat00916a/mit.001492509?guest=true&pride=true&source=cat00916a')
        assert_response :success
      end
    end
  end

  test 'handle db simultaneous user limit reached' do
    VCR.use_cassette('record: simultaneous user limit reached',
                     allow_playback_repeats: true) do
      assert_raises RecordController::DbLimitReached do
        get record_url('phl', 'PHL2218518')
      end
    end
  end

  test 'generic eds record error handler' do
    VCR.use_cassette('record: unknown error handler',
                     allow_playback_repeats: true) do
      assert_raises RecordController::UnknownEdsError do
        get record_url('phl', 'PHL2218518')
      end
    end
  end
end
