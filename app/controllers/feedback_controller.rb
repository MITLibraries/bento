class FeedbackController < ApplicationController
  before_action :validate_message!, only: [:submit]

  def index; end

  def submit
    FeedbackMailer.feedback_email(params[:feedback_message],
                                  request.remote_ip, params[:previous_page],
                                  params[:contact_email],
                                  request.env['HTTP_USER_AGENT']).deliver_now
  end

  private

  def validate_message!
    return if params[:feedback_message].present?
    flash[:error] = 'A feedback message is required.'
    redirect_to feedback_url
  end
end
