class FeedbackController < ApplicationController
  def index; end

  def submit
    FeedbackMailer.feedback_email('This is an important message!',
                                  request.remote_ip, 'http://example.com/stuff',
                                  request.env['HTTP_USER_AGENT']).deliver_now
  end
end
