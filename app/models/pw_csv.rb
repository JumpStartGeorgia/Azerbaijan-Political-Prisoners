# Handles csv files
# About name: PwCsv stands for Prisoners Watch CSV; avoids conflict with CSV gem
class PwCsv
  def self.fileTimeStamp
    Time.now.strftime(I18n.t('shared.datetime.full'))
  end
  private_class_method :fileTimeStamp

  def self.getCsvFileName(model, timeStamp)
    "#{model.model_name.plural}_#{timeStamp}.csv"
  end
  private_class_method :getCsvFileName

  def self.createCsvZip(csv_zip, timeStamp)
    require 'zip'

    # Calls to_csv on each of these models and includes it in the zip
    csv_models = [Prison, Tag, Article, Prisoner, Incident, CriminalCode]

    csv_dir = Pathname.new(File.dirname(csv_zip))
    FileUtils.mkdir_p(csv_dir)

    # Create csv files
    csv_models.each do |csv_model|
      File.open(csv_dir.join(getCsvFileName(csv_model, timeStamp)), 'w') { |file| file.write(csv_model.to_csv) }
    end

    # Create zip from csv files
    Zip::File.open(csv_zip, Zip::File::CREATE) do |zipfile|
      csv_models.each do |csv_model|
        zipfile.add(getCsvFileName(csv_model, timeStamp), csv_dir.join(getCsvFileName(csv_model, timeStamp)))
      end
    end

    # Delete csv files
    csv_models.each do |csv_model|
      File.delete(csv_dir.join(getCsvFileName(csv_model, timeStamp)))
    end
  end
  private_class_method :createCsvZip

  def self.zip_all
    csv_zip = Dir.glob(Rails.root.join('public', 'generated', 'csv', I18n.locale.to_s, 'political_prisoner_data_*.zip'))[0]

    unless csv_zip
      timeStamp = fileTimeStamp
      csv_zip = Rails.root.join('public', 'generated', 'csv', I18n.locale.to_s, "political_prisoner_data_#{timeStamp}.zip")
      createCsvZip(csv_zip, timeStamp)
    end

    return csv_zip
  end
end
