require 'test_helper'

class AlephTest < ActionDispatch::IntegrationTest
  test 'map_link barker' do
    VCR.use_cassette('record status barker', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01001251550' }
      assert_response :success
      assert_select('.map-link') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/barker/'))
      end
    end
  end

  test 'map_link dewey' do
    VCR.use_cassette('record status dewey', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01002519066' }
      assert_response :success
      assert_select('.map-link') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/dewey/'))
      end
    end
  end

  test 'map_link hayden' do
    VCR.use_cassette('record status hayden', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01001739356' }
      assert_response :success
      assert_select('.map-link') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/hayden/'))
      end
    end
  end

  test 'map_link archives' do
    VCR.use_cassette('record status archives', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01001975671' }
      assert_response :success
      assert_select('.map-link') do |value|
        assert(value.last[:href].include?('libraries.mit.edu/archives/'))
      end
    end
  end

  test 'map_link music' do
    VCR.use_cassette('record status music', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01001528789' }
      assert_response :success
      assert_select('.map-link') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/music/'))
      end
    end
  end

  test 'map_link rotch' do
    VCR.use_cassette('record status rotch', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01002403936' }
      assert_response :success
      assert_select('.map-link') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/rotch/'))
      end
    end
  end

  test 'local course reserve record' do
    VCR.use_cassette('record status reserve', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT30000105498' }
      assert_response :success
      assert_select('.map-link') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/rotch/'))
      end
    end
  end

  test 'place hold link displayed' do
    VCR.use_cassette('realtime aleph') do
      get full_item_status_path, params: { id: 'MIT01001739356' }
      assert_select 'a', text: 'Place Hold' do |value|
        parsed_url = URI.parse(value.first[:href])
        assert_equal parsed_url.host, 'library.mit.edu'
        assert_equal parsed_url.path, '/F'

        # You have to use hashrockets, because otherwise it converts the strings
        # into symbols, which then don't match the keys of the array that
        # CGI.parse spits out.
        expected_params = {
          'adm_doc_number' => ['001739356'],
          'doc_library' => ['MIT50'],
          'func' => ['item-hold-request'],
          'item_sequence' => ['000010']
        }
        params = CGI.parse(parsed_url.query)

        # We can't just check that the querystring equals an expected
        # querystring, because hashes don't guarantee order, so the to_query
        # part of item_request_url may not return in any particular order.
        assert_equal expected_params, params
      end
    end
  end
end
