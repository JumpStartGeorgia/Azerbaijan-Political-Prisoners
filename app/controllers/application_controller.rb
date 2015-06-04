class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  cache_sweeper :generated_sweeper

  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def fileTimeStamp
    Time.now.strftime(t('app.datetime.full'))
  end


  rescue_from CanCan::AccessDenied do |_exception|
    if user_signed_in?
      not_authorized
    else
      not_found
    end
  end

  #######################
  #######################
  def not_authorized
    redirect_to :back, alert: t('app.msgs.not_authorized')
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end

  def not_found
    fail ActionController::RoutingError.new(t('app.msgs.does_not_exist'))
  end

end
