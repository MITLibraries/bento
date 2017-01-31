# Preview all emails at http://localhost:3000/rails/mailers/feedback_mailer
class FeedbackMailerPreview < ActionMailer::Preview
  def feedback_email
    msg = 'This is a message. <p>It is important</p>'
    ip = '0.0.0.0'
    page = 'http://example.com/search/thing?q=popcorn%20rules'
    ua = 'Netscape 4.0'
    FeedbackMailer.feedback_email(msg, ip, page, ua)
  end
end
