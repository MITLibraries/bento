require 'test_helper'

class RecordControllerTest < ActionDispatch::IntegrationTest
  test 'redirects full record to Primo record if available' do
    VCR.use_cassette('sru book', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'cat00916a', an: 'mit.001492509' }
      assert_response 308
      assert_redirected_to 'https://mit.primo.exlibrisgroup.com/discovery/fulldisplay?docid=alma990014925090206761&vid=FAKE_PRIMO_VID'
    end
    VCR.use_cassette('sru journal', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'cat00916a', an: 'mit.000292123' }
      assert_response 308
      assert_redirected_to 'https://mit.primo.exlibrisgroup.com/discovery/fulldisplay?docid=alma990002921230206761&vid=FAKE_PRIMO_VID'
    end
  end

  test 'redirects direct link to Primo record if available' do
    VCR.use_cassette('sru book', allow_playback_repeats: true) do
      get record_direct_link_url, params: { db_source: 'cat00916a', an: 'mit.001492509' }
      assert_response 308
      assert_redirected_to 'https://mit.primo.exlibrisgroup.com/discovery/fulldisplay?docid=alma990014925090206761&vid=FAKE_PRIMO_VID'
    end
    VCR.use_cassette('sru journal', allow_playback_repeats: true) do
      get record_direct_link_url, params: { db_source: 'cat00916a', an: 'mit.000292123' }
      assert_response 308
      assert_redirected_to 'https://mit.primo.exlibrisgroup.com/discovery/fulldisplay?docid=alma990002921230206761&vid=FAKE_PRIMO_VID'
    end
  end

  test 'redirects full record to splash page if Primo record is not available' do
    VCR.use_cassette('sru article', allow_playback_repeats: true) do
      get record_url, params: { db_source: 'aci', an: '123877356' }
      assert_response 308
      assert_redirected_to ENV.fetch('PRIMO_SPLASH_PAGE')
    end
  end

  test 'redirects direct link to to splash page if Primo record is not available' do
    get record_direct_link_url, params: { db_source: 'aci', an: '123877356' }
    assert_response 308
    assert_redirected_to ENV.fetch('PRIMO_SPLASH_PAGE')
  end
end
