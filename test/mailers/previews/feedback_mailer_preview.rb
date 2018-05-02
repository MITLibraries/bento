# Preview all emails at http://localhost:3000/rails/mailers/feedback_mailer
class FeedbackMailerPreview < ActionMailer::Preview
  def feedback_email
    msg = 'This is a message. <p>It is important</p>'
    guest = true
    page = 'http://example.com/search/thing?q=popcorn%20rules'
    ua = 'Netscape 4.0'
    contact_name = 'Firsty Lastoson'
    contact_email = 'yo@example.com'
    FeedbackMailer.feedback_email(msg, guest, page, contact_email, contact_name, ua)
  end
end
