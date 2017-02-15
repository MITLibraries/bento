class FeedbackController < ApplicationController
  before_action :validate_message!, only: [:submit]
  before_action :recaptcha!, only: [:submit]

  def index; end

  def submit
    FeedbackMailer.feedback_email(params[:feedback_message],
                                  request.remote_ip, params[:previous_page],
                                  params[:contact_email], params[:contact_name],
                                  request.env['HTTP_USER_AGENT']).deliver_now
  end

  private

  def recaptcha!
    return if verify_recaptcha
    flash[:error] = 'Please confirm you are not a robot.'
    redirect_to feedback_url
  end

  def validate_message!
    return if params[:feedback_message].present?
    flash[:error] = 'A feedback message is required.'
    redirect_to feedback_url
  end
end
