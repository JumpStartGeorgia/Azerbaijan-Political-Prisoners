class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  cache_sweeper :generated_sweeper

  before_action :set_locale
  before_action :set_global_variables
  before_action :set_addthis_id

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    gon.locale = I18n.locale
  end

  def set_global_variables
    @show_page_title = true
  end

  def set_addthis_id
    gon.addthis_id = ENV['ADD_THIS_TOOLBOX']
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
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
    redirect_to :back, alert: t('shared.msgs.not_authorized')
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end

  def not_found(redirect_path = root_path)
    Rails.logger.debug('Not found redirect')
    redirect_to redirect_path,
                notice: t('shared.msgs.does_not_exist')
  end
end
