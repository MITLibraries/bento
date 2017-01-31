class FeedbackMailer < ApplicationMailer
  def feedback_email(msg, ip, page, contact_email, ua)
    @ip = ip
    @msg = msg
    @page = page
    @ua = ua
    @contact_email = contact_email
    mail(to: 'test@example.com', subject: 'MIT Bento Feedback')
  end
end
