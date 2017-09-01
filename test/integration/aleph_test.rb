require 'test_helper'

class AlephTest < ActionDispatch::IntegrationTest
  test 'map_link barker' do
    VCR.use_cassette('record status barker', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01001251550' }
      assert_response :success
      assert_select('.fa-map-marker') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/barker/'))
      end
    end
  end

  test 'map_link dewey' do
    VCR.use_cassette('record status dewey', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01002519066' }
      assert_response :success
      assert_select('.fa-map-marker') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/dewey/'))
      end
    end
  end

  test 'map_link hayden' do
    VCR.use_cassette('record status hayden', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01001739356' }
      assert_response :success
      assert_select('.fa-map-marker') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/hayden/'))
      end
    end
  end

  test 'map_link archives' do
    VCR.use_cassette('record status archives', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01001975671' }
      assert_response :success
      assert_select('.fa-map-marker') do |value|
        assert(value.last[:href].include?('libraries.mit.edu/archives/'))
      end
    end
  end

  test 'map_link music' do
    VCR.use_cassette('record status music', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01001528789' }
      assert_response :success
      assert_select('.fa-map-marker') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/music/'))
      end
    end
  end

  test 'map_link rotch' do
    VCR.use_cassette('record status rotch', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT01002403936' }
      assert_response :success
      assert_select('.fa-map-marker') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/rotch/'))
      end
    end
  end

  test 'local course reserve record' do
    VCR.use_cassette('record status reserve', allow_playback_repeats: true) do
      get full_item_status_path, params: { id: 'MIT30000105498' }
      assert_response :success
      assert_select('.fa-map-marker') do |value|
        assert(value.first[:href].include?('libraries.mit.edu/rotch/'))
      end
    end
  end
end
