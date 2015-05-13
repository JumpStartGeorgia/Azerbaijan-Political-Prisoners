class GeneratedSweeper < ActionController::Caching::Sweeper
  observe Prisoner, Prison, Article, Tag, CriminalCode

  def after_commit(record)
    remove_generated
  end

  # Removes generated files (such as json, csv) that are rendered obselete when a prisoner is updated
  def remove_generated
    ["imprisoned_count_timeline", "article_incident_counts_chart", "prison_prisoner_count_chart"].each do |json_data|
      path = Rails.public_path.join("data/" + json_data + ".json")
      File.delete(path) if File.exists?(path)
    end

    csv_zip = Dir.glob(Rails.public_path.join('system', 'csv', "political_prisoner_data_*.zip"))[0]
    File.delete(csv_zip) if csv_zip != nil && File.exists?(csv_zip)
  end
end
