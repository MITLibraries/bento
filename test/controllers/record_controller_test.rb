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
      assert_raises RecordController::NoSuchRecordError do
        get record_url('dog00916a', 'mit.001492509')
      end
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
      assert_raises RecordController::NoSuchRecordError do
        get record_direct_link_url('dog00916a', 'mit.001492509')
      end
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
                   'http://www.example.com/record/cat00916a/mit.001492509?guest=true&source=cat00916a')
      assert_response :success
    end
  end

  test 'cache_path for non-guests' do
    VCR.use_cassette('record: bananas nonguest',
                     allow_playback_repeats: true) do
      ActionDispatch::Request.any_instance.stubs(:remote_ip)
                             .returns('18.42.101.101')
      get record_url('cat00916a', 'mit.001492509')
      assert_equal(@controller.send(:cache_path),
                   'http://www.example.com/record/cat00916a/mit.001492509?guest=false&source=cat00916a')
      assert_response :success
    end
  end
end
