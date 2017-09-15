require 'test_helper'

class RecordTest < ActionDispatch::IntegrationTest
  test 'article title is shown' do
    VCR.use_cassette('record: article', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'aci', an: '123877356' }
      assert_response :success
      assert_select('h2') do |value|
        assert(value.text.include?('Ultrasensitive Label-Free Sensing of IL-6'))
      end
    end
  end

  test 'book title is shown' do
    VCR.use_cassette('record: book', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'cat00916a', an: 'mit.001492509' }
      assert_response :success
      assert_select('h2') do |value|
        assert(value.text.include?('Bananas : how the United Fruit Company'))
      end
    end
  end

  test 'journal title is shown' do
    VCR.use_cassette('record: journal', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'cat00916a', an: 'mit.000292123' }
      assert_response :success
      assert_select('h2') do |value|
        assert(value.text.include?('Blood.'))
      end
    end
  end

  test 'back to search results link is shown where available' do
    VCR.use_cassette('record: book', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'cat00916a',
                                an: 'mit.001492509',
                                previous: 'bananas' }
      assert_response :success
      assert_select('a[href=?]', search_bento_path(q: 'bananas')) do |value|
        assert(value.text.include?('Back to search results'))
      end
    end
  end

  test 'back to search results link not shown where unavailable' do
    VCR.use_cassette('record: book', allow_playback_repeats: true) do
      get record_url, params:
                        { db_source: 'cat00916a',
                          an: 'mit.001492509' } # note: no 'previous' param
      assert_response :success
      assert response.body.exclude? 'Back to search results'
    end
  end

  test 'course reserve material is viewable' do
    VCR.use_cassette('record: course reserve', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'cat01763a', an: 'mitcr.000105015' }
      assert_response :success
      assert_select('h2') do |value|
        assert(value.text.include?('Economic analysis for business decisions'))
      end
    end
  end

  test 'view online button is shown' do
    VCR.use_cassette('record: article', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'aci', an: '123877356' }
      assert_select 'a.button-primary', text: 'View online'
      assert_select 'a', text: 'Check for online copy', count: 0
    end
  end

  test 'check for online copy link shown when SFX URL is not fulltext' do
    VCR.use_cassette('record: journal', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'cat00916a', an: 'mit.000292123' }
      assert_response :success
      assert_select 'a.button-primary', text: 'View online', count: 0
      assert_select 'a', text: 'Check for online copy'
    end
  end

  test 'check for view online button shown when SFX URL is fulltext' do
    VCR.use_cassette('record: sfx fulltext', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'mdc', an: '28632713' }
      assert_response :success
      assert_select 'a.button-primary', text: 'View online'
      assert_select 'a', text: 'Check for online copy', count: 0
    end
  end
end
