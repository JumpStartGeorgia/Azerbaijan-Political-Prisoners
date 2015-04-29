require 'zip'
require 'csv'

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

  def to_csv
    csv_dir = Rails.root.join('public', 'system', 'csv')
    csv_zip = csv_dir.join('political_prisoner_data.zip')

    unless File.exists?(csv_zip)
      createCsvZip(csv_dir, csv_zip)
    end

    send_file csv_zip, type: 'application/zip'
  end

  private

  def createCsvZip(csv_dir, csv_zip)
    csv_models = [Prison, Tag, Article]

    FileUtils.mkdir_p(csv_dir)

    csv_models.each do |csv_model|
      File.open(csv_dir.join(getCsvFileName(csv_model)), 'w') { |file| file.write(csv_model.all.to_csv) }
    end

    Zip::File.open(csv_zip, Zip::File::CREATE) do |zipfile|
      csv_models.each do |csv_model|
        zipfile.add(getCsvFileName(csv_model), csv_dir.join(getCsvFileName(csv_model)))
      end
    end

    csv_models.each do |csv_model|
      File.delete(csv_dir.join(getCsvFileName(csv_model)))
    end
  end

  def getCsvFileName(model)
    return model.model_name.plural + '.csv'
  end
end
