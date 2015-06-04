class RootController < ApplicationController
  def index
    gon.imprisoned_count_timeline_prisoners_path = imprisoned_count_timeline_prisoners_path
    gon.article_incident_counts_articles_path = article_incident_counts_articles_path
    gon.prison_prisoner_counts_prisons_path = prison_prisoner_counts_prisons_path
    gon.prisoners_path = prisoners_path
    gon.articles_path = articles_path
    gon.prisons_path = prisons_path

    @featured_prisoner = Prisoner.offset(rand(Prisoner.count)).first
    @featured_prisoner_inc = @featured_prisoner.incidents.last
    @currently_imprisoned_count = Prisoner.currently_imprisoned_count
  end

  def about
  end

  def methodology
  end

  def disclaimer
  end

  def to_csv_zip
    csv_zip = Dir.glob(Rails.root.join('public', 'system', 'csv', 'political_prisoner_data_*.zip'))[0]
    unless csv_zip
      timeStamp = fileTimeStamp
      csv_zip = Rails.root.join('public', 'system', 'csv', "political_prisoner_data_#{timeStamp}.zip")
      createCsvZip(csv_zip, timeStamp)
    end
    send_file csv_zip, type: 'application/zip'
  end

  private

  def createCsvZip(csv_zip, timeStamp)
    require 'zip'

    csv_models = [Prison, Tag, Article, Prisoner, Incident]

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

  def getCsvFileName(model, timeStamp)
    "#{model.model_name.plural}_#{timeStamp}.csv"
  end
end
