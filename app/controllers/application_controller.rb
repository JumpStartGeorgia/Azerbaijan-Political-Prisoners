class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to :back, alert: "You are not authorized to perform that action."
    else
      not_found
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end