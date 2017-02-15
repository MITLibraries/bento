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

    assert_equal('MIT Bento Feedback', feedback_email.subject)
    assert_equal('test@example.com', feedback_email.to[0])
    assert_match(/The following feedback was submitted/,
                 feedback_email.body.to_s)
    assert_match(/Popcorn is cool./,
                 feedback_email.body.to_s)
    assert_match(/Client IP: 127.0.0.1/,
                 feedback_email.body.to_s)
    assert_match(/Contact Email: yo@example.com/,
                 feedback_email.body.to_s)
    assert_match(/Contact Name: Firsty Lastoson/,
                 feedback_email.body.to_s)
    assert_match(%r{Originating page: http://example.com/hi},
                 feedback_email.body.to_s)
  end
end
