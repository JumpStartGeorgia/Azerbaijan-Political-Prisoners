class GeneratedSweeper < ActionController::Caching::Sweeper
  observe Prisoner, Prison, Article, Tag, CriminalCode

  def after_commit(_record)
    remove_generated
  end

  # Removes generated files (such as json, csv) that are rendered obselete when a prisoner is updated
  def remove_generated
    remove_paths = [
      Rails.public_path.join('system', 'json', 'imprisoned_count_timeline.json'),
      Rails.public_path.join('system', 'json', 'article_incident_counts_chart.json'),
      Rails.public_path.join('system', 'json', 'prison_prisoner_count_chart.json'),
      Dir.glob(Rails.public_path.join('system', 'csv', 'political_prisoner_data_*.zip'))[0]
    ]

    remove_paths.each do |path|
      File.delete(path) if !path.nil? && File.exist?(path)
    end
  end
end
