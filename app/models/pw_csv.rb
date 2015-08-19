# Handles csv files
# About name: PwCsv stands for Prisoners Watch CSV; avoids conflict with CSV gem
class PwCsv
  def self.plural_name(model)
    model.model_name.plural
  end
  private_class_method :plural_name

  def self.create_csv_files(csv_models, csv_dir)
    csv_models.each do |csv_model|
      new_csv_file_path = csv_dir.join(GeneratedFile.clean_filename(plural_name(csv_model), 'csv'))

      File.open(new_csv_file_path, 'w') do |file|
        file.write(csv_model.to_csv)
      end
    end
  end
  private_class_method :create_csv_files

  def self.create_zip_from_csv_files(csv_zip, csv_models, csv_dir)
    Zip::File.open(csv_zip, Zip::File::CREATE) do |zipfile|
      csv_models.each do |csv_model|
        csv_file_path = Dir.glob(csv_dir.join("#{plural_name(csv_model)}_*.csv"))[0]
        csv_file_name = File.basename(csv_file_path)

        zipfile.add(csv_file_name, csv_file_path)
      end
    end
  end
  private_class_method :create_zip_from_csv_files

  def self.remove_csv_files(csv_models, csv_dir)
    csv_models.each do |csv_model|
      csv_file_path = Dir.glob(csv_dir.join("#{plural_name(csv_model)}_*.csv"))[0]

      File.delete(csv_file_path)
    end
  end
  private_class_method :remove_csv_files

  def self.create_csv_zip(csv_zip)
    require 'zip'

    # Calls to_csv on each of these models and includes it in the zip
    csv_models = [Prison, Tag, Article, Prisoner, Incident, CriminalCode]

    # Create the directory to contain the csv files
    csv_dir = Pathname.new(File.dirname(csv_zip))
    FileUtils.mkdir_p(csv_dir)

    create_csv_files(csv_models, csv_dir)
    create_zip_from_csv_files(csv_zip, csv_models, csv_dir)
    remove_csv_files(csv_models, csv_dir)
  end
  private_class_method :create_csv_zip

  def self.zip_all
    csv_zip = Dir.glob(Rails.root.join('public', 'generated', 'csv', I18n.locale.to_s, 'political_prisoner_data_*.zip'))[0]

    unless csv_zip
      csv_zip = Rails.root
                .join('public',
                      'generated',
                      'csv',
                      I18n.locale.to_s,
                      GeneratedFile.clean_filename('political_prisoner_data', 'zip'))

      create_csv_zip(csv_zip)
    end

    csv_zip
  end
end
