class TimdexController < ApplicationController
  class NoSuchRecordError < StandardError; end
  class UnknownTimdexError < StandardError; end

  def record
    response = Timdex.new(ENV['TIMDEX_USER'], ENV['TIMDEX_PASS']).retrieve(params[:id])
    if response['status'] == 200
      @record = response['record']
    elsif response['status'] == 404
      raise TimdexController::NoSuchRecordError, "Record not found"
    else
      raise TimdexController::UnknownTimdexError, "¯\\\_(ツ)_/¯"
    end
  end
end
