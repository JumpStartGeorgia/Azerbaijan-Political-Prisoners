class RootController < ApplicationController
  def index
    @currently_imprisoned_count = Prisoner.currently_imprisoned_count
  end

  def to_csv_zip
    csv_zip = Rails.root.join('public', 'system', 'csv', 'political_prisoner_data.zip')

    unless File.exists?(csv_zip)
      createCsvZip(csv_zip)
    end

    send_file csv_zip, type: 'application/zip'
  end

  private

  def createCsvZip(csv_zip)
    require 'zip'

    csv_models = [Prison, Tag, Article]

    csv_dir = Pathname.new(File.dirname(csv_zip))
    FileUtils.mkdir_p(csv_dir)

    # Create csv files
    csv_models.each do |csv_model|
      File.open(csv_dir.join(getCsvFileName(csv_model)), 'w') { |file| file.write(csv_model.to_csv) }
    end

    # Create zip from csv files
    Zip::File.open(csv_zip, Zip::File::CREATE) do |zipfile|
      csv_models.each do |csv_model|
        zipfile.add(getCsvFileName(csv_model), csv_dir.join(getCsvFileName(csv_model)))
      end
    end

    # Delete csv files
    csv_models.each do |csv_model|
      File.delete(csv_dir.join(getCsvFileName(csv_model)))
    end
  end

  def getCsvFileName(model)
    return model.model_name.plural + '.csv'
  end
end