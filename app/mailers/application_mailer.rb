class ApplicationMailer < ActionMailer::Base
  default from: ENV['FEEDBACK_MAIL_TO']
  layout 'mailer'
end
