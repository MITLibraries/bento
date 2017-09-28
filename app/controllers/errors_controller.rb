class ErrorsController < ApplicationController
  def generic_handler(status)
    respond_to do |format|
      format.html { render status: status }
      format.all { head status }
    end
  end

  def not_found
    generic_handler(404)
  end

  def i_am_a_teapot
    generic_handler(418)
  end

  # This controller can be expanded to cover any of the exception handlers in
  # rails/actionpack/lib/action_dispatch/middleware/exception_wrapper.rb .
  # For example, to cover :method_not_allowed, you would do the following:
  #   * define a method_not_allowed function in this file
  #   * add app/views/errors/method_not_allowed.erb
  #   * add a match line to config/routes.rb by analogy with the 404 handler
  #
  # In order to test that your exception handler is working:
  #   * uncomment the consider_all_requests_local line in config/development.rb
  #   * create a controller which raises the desired exception
  #   * visit the route for that controller
  #   * (You may have to restart the server for the changes to take effect.)
  #
  # If you would like to define custom errors, and then bind them to native
  # error handlers, so that Rails middleware will catch them and display 404
  # or whatever:
  #   * define your error
  #   * in config/application.rb, add something like:
  #       config.action_dispatch.rescue_responses.merge!(
  #         'RecordController::NoSuchRecordError' => :not_found
  #       )
  # Again, see the Rails exception_wrapper.rb file for available error handler
  # functions.
end
