class FeedbackMailer < ApplicationMailer
  def feedback_email(msg, guest, page, contact_email, contact_name, ua)
    @guest = if guest
               'Non-MIT IP Detected'
             else
               'MIT IP Detected'
             end
    @msg = msg
    @page = page
    @ua = ua
    @contact_email = contact_email
    @contact_name = contact_name
    mail(to: ENV['FEEDBACK_MAIL_TO'],
         subject: 'Search feedback - MIT Libraries')
  end
end
