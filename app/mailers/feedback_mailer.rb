class FeedbackMailer < ApplicationMailer
  def feedback_email(msg, ip, page, ua)
    @ip = ip
    @msg = msg
    @page = page
    @ua = ua
    mail(to: 'test@example.com', subject: 'MIT Bento Feedback')
  end
end
