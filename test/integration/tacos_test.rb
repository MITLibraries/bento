require 'test_helper'

class TacosTest < ActionDispatch::IntegrationTest
  test 'suggested resources with no query' do
    get '/suggested_resources'
    assert_response :success
  end

  test 'suggested resources with unmatched query' do
    VCR.use_cassette('tacos suggested no match', allow_playback_repeats: true) do
      get '/suggested_resources?q=purple'
      assert_response :success
      assert_empty @controller.view_assigns['suggested_resources']
      assert_select '.suggested-resources-box', count: 0
    end
  end

  test 'suggested resources with matched query' do
    VCR.use_cassette('tacos suggested resources match', allow_playback_repeats: true) do
      get '/suggested_resources?q=INDSTAT'
      assert_response :success
      assert_select '.suggested-resources-box .title', text: 'UNIDO Statistics Data Portal (IDSB, INDSTAT4, INDSTAT2)'
      assert_select 'a[href=?]', 'https://libguides.mit.edu/unido-data'
    end
  end

  test 'suggested resources with matched term but no TACOS_URL' do
    ClimateControl.modify('TACOS_URL': nil) do
      get '/suggested_resources?q=INDSTAT'
      assert_response :success
      assert_select '.suggested-resources-box .title', text: 'UNIDO Statistics Data Portal (IDSB, INDSTAT4, INDSTAT2)',
                    count: 0
    end
  end

  test 'suggested resources with matched term but no ORIGINS' do
    ClimateControl.modify('ORIGINS': nil) do
      get '/suggested_resources?q=INDSTAT'
      assert_response :success
      assert_select '.suggested-resources-box .title', text: 'UNIDO Statistics Data Portal (IDSB, INDSTAT4, INDSTAT2)',
                    count: 0
    end
  end
end
