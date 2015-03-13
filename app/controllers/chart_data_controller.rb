class ChartDataController < ApplicationController
  def imprisoned_count_timeline
    path = Rails.public_path.join('chart_data/imprisoned_count_timeline.json')

    respond_to do |format|
        format.json { render json: File.read(path) }
    end
  end
end