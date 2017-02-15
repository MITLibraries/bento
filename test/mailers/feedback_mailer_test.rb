require 'test_helper'

class FeedbackMailerTest < ActionMailer::TestCase
  def test_feedback_email
    # Create the email and store it for further assertions
    email = FeedbackMailer.feedback_email('This is an important message!',
                                          '0.0.0.0', 'http://example.com/stuff',
                                          'yo@example.com', 'Firsty Lastoson',
                                          'Netscape 4.0')

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['test@example.com'], email.from
    assert_equal ['test@example.com'], email.to
    assert_equal 'MIT Bento Feedback', email.subject
    assert_equal read_fixture('feedback_email').join, email.body.to_s
  end
end
