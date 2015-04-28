require 'zip'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      not_authorized
    else
      not_found
    end
  end

  def not_authorized
    redirect_to :back, alert: "You are not authorized to perform that action."
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def export_to_csv
    prisons_csv = Rails.root.join('public', 'system', 'csv', 'prisons.csv')
    FileUtils.mkdir_p(File.dirname(prisons_csv))

    File.open(prisons_csv, 'w') { |file| file.write(Prison.all.to_csv) }

    Zip::File.open(Rails.root.join('public', 'system', 'csv', 'political_prisoner_data.zip'), Zip::File::CREATE) do |zipfile|
      zipfile.add('prisons.csv', prisons_csv)
    end

    redirect_to '/'
  end
end
