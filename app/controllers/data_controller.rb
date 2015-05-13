class DataController < ApplicationController
  def prison_prisoner_counts
    if !File.exists?(Rails.public_path.join('data/prison_prisoner_count_chart.json'))
      Prison.generate_prison_prisoner_count_chart_json
    end

    respond_with_public_json('data/prison_prisoner_count_chart.json')
  end

  def article_incident_counts
    if !File.exists?(Rails.public_path.join('data/article_incident_counts_chart.json'))
      Article.generate_highest_incident_counts_chart_json
    end

    respond_with_public_json('data/article_incident_counts_chart.json')
  end

  private
  def respond_with_public_json(path)
    respond_to do |format|
      format.json { render json: File.read(Rails.public_path.join(path)) }
    end
  end
end
