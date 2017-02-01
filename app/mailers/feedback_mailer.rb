class FeedbackMailer < ApplicationMailer
  def feedback_email(msg, ip, page, contact_email, ua)
    @ip = ip
    @msg = msg
    @page = page
    @ua = ua
    @contact_email = contact_email
    mail(to: ENV['FEEDBACK_MAIL_TO'], subject: 'MIT Bento Feedback')
  end
end
