class RootController < ApplicationController
  def index
    @currently_imprisoned_count = Prisoner.currently_imprisoned_count

    if !File.exists?(Rails.public_path.join('chart_data/imprisoned_count_timeline.json'))
      Prisoner.generate_imprisoned_count_timeline_json
    end

    if !File.exists?(Rails.public_path.join('chart_data/prison_prisoner_count_chart.json'))
      Prison.generate_prison_prisoner_count_chart_json
    end

    if !File.exists?(Rails.public_path.join('chart_data/article_incident_counts_chart.json'))
      Article.generate_highest_incident_counts_chart_json
    end
  end
end