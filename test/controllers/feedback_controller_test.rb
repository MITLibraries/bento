require 'test_helper'

class FeedbackControllerTest < ActionDispatch::IntegrationTest
  test 'index' do
    get feedback_path
    assert_response :success
  end

  test 'submit feedback' do
    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      post feedback_submit_url, params: {
        feedback_message: 'Popcorn is cool.',
        contact_email: 'yo@example.com',
        contact_name: 'Firsty Lastoson',
        previous_page: 'http://example.com/hi'
      }
    end
    feedback_email = ActionMailer::Base.deliveries.last

    assert_equal('Search feedback - MIT Libraries',
                 feedback_email.subject)
    assert_equal('test@example.com', feedback_email.to[0])
    assert_match(/Popcorn is cool./,
                 feedback_email.body.to_s)
    assert_match(/Client IP: Non-MIT IP Detected/,
                 feedback_email.body.to_s)
    assert_match(/Contact Email: yo@example.com/,
                 feedback_email.body.to_s)
    assert_match(/Contact Name: Firsty Lastoson/,
                 feedback_email.body.to_s)
    assert_match(%r{Originating page: http://example.com/hi},
                 feedback_email.body.to_s)
  end

  test 'submit_feedback_internal_ip' do
    ActionDispatch::Request.any_instance.stubs(:remote_ip)
                           .returns('18.42.101.101')
    post feedback_submit_url, params: {
      feedback_message: 'Popcorn is cool.',
      contact_email: 'yo@example.com',
      contact_name: 'Firsty Lastoson',
      previous_page: 'http://example.com/hi'
    }

    feedback_email = ActionMailer::Base.deliveries.last

    refute_match(/Client IP: Non-MIT IP Detected/,
                 feedback_email.body.to_s)
    assert_match(/Client IP: MIT IP Detected/,
                 feedback_email.body.to_s)
  end
end
