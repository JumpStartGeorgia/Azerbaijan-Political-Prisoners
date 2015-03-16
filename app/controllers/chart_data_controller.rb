class ChartDataController < ApplicationController
  def imprisoned_count_timeline
    respond_with_public_json('chart_data/imprisoned_count_timeline.json')
  end

  def prison_prisoner_counts
    respond_with_public_json('chart_data/prison_prisoner_count_chart.json')
  end

  def article_incident_counts
    respond_with_public_json('chart_data/article_incident_counts_chart.json')
  end

  private
  def respond_with_public_json(path)
    respond_to do |format|
      format.json { render json: File.read(Rails.public_path.join(path)) }
    end
  end
end