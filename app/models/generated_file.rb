# Class of all files that are generated once and then used multiple times, so
# that their data-intensive processes do not need to be repeated so often
class GeneratedFile
  # Directory containing all generated files
  def self.generated_dir
    Rails.root.join('public', 'generated')
  end
  private_class_method :generated_dir

  # Array of all generated file methods; each method generates its
  # corresponding file IF it does not exist, and then returns the path to that
  # file.
  def self.files
    [
      Prisoner.imprisoned_count_timeline_json,
      Article.charge_counts_chart_json,
      Prison.current_prisoner_counts_chart_json,
      PwCsv.zip_all
    ]
  end
  private_class_method :files

  def self.generate_for_locale(locale = I18n.default_locale)
    I18n.locale = locale
    files.each do |file|
      Rails.logger.info("Generated #{locale} file: #{file}")
    end
  end
  private_class_method :generate_for_locale

  # Generate all files for all locales
  def self.generate
    I18n.available_locales.each do |locale|
      generate_for_locale(locale)
    end
  end

  # Remove the generated directory
  def self.remove
    FileUtils.rm_rf(generated_dir)
    Rails.logger.info("Removed #{generated_dir}")
  end

  # Remove the generated directory and then generate all files
  def self.regenerate
    remove
    generate
  end

  # Returns a string that is cleaned for use in filename
  def self.clean_string_in_filename(str)
    str.to_ascii.gsub(/[^a-z0-9\-]+/i, '_')
  end

  # Returns localized time stamp to use in file names
  def self.timeStamp
    clean_string_in_filename(Time.now.strftime(I18n.t('shared.datetime.full')))
  end

  # Returns cleaned file name with extension
  def self.clean_filename(str, extension, timeStamp = self.timeStamp)
    "#{clean_string_in_filename(str)}_#{timeStamp}.#{extension}"
  end
end
