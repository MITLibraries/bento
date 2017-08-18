class RecordController < ApplicationController
  def record
    @record_id = params[:id]
    return redirect_to root_url unless @record_id
    render 'record'
  end
end