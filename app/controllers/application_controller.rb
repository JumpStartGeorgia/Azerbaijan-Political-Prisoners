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
    csv_dir = Rails.root.join('public', 'system', 'csv')
    FileUtils.mkdir_p(csv_dir)

    csv_files = ['prisons.csv', 'tags.csv']
    File.open(csv_dir.join('prisons.csv'), 'w') { |file| file.write(Prison.all.to_csv) }
    File.open(csv_dir.join('tags.csv'), 'w') { |file| file.write(Tag.all.to_csv) }

    Zip::File.open(csv_dir.join('political_prisoner_data.zip'), Zip::File::CREATE) do |zipfile|
      csv_files.each do |csv_file|
        zipfile.add(csv_file, csv_dir.join(csv_file))
      end
    end

    send_file csv_dir.join('political_prisoner_data.zip'), type: 'application/zip'
  end
end
