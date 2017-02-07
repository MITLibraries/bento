require 'test_helper'

class FeedbackTest < ActionDispatch::IntegrationTest
  test 'feedback_message and contact_email queues email' do
    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      post('/feedback',
           params: { contact_email: 'yo@example.com',
                     feedback_message: 'Message this!' })
      assert_response(:success)
      assert_select('.title-page', 'Thanks for your feedback')
    end

    feedback_email = ActionMailer::Base.deliveries.last

    assert_equal('MIT Bento Feedback',
                 feedback_email.subject)
    assert_match(/yo@example.com/, feedback_email.body.to_s)
    assert_match(/Message this!/, feedback_email.body.to_s)
  end

  test 'no feedback_message does not queue email' do
    assert_difference('ActionMailer::Base.deliveries.size', 0) do
      post('/feedback',
           params: { contact_email: 'yo@example.com',
                     feedback_message: '' })
      follow_redirect!
      assert_select('.alert') do |value|
        assert(value.text.include?('A feedback message is required.'))
      end
    end
  end

  test 'feedback_message with no contact_email queues email' do
    assert_difference('ActionMailer::Base.deliveries.size', +1) do
      post('/feedback',
           params: { contact_email: '',
                     feedback_message: 'Message this!' })
      assert_response(:success)
      assert_select('.title-page', 'Thanks for your feedback')
    end
  end

  test 'feedback with no recaptcha redirects to feedback_url' do
    FeedbackController.any_instance.stubs(:verify_recaptcha).returns(false)
    assert_difference('ActionMailer::Base.deliveries.size', 0) do
      post feedback_submit_url, params: {
        feedback_message: 'Popcorn is cool.',
        contact_email: 'yo@example.com',
        previous_page: 'http://example.com/hi'
      }
      follow_redirect!
      assert_select('.alert') do |value|
        assert(value.text.include?('Please confirm you are not a robot.'))
      end
    end
  end
end
