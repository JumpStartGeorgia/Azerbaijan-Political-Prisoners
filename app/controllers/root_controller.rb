class RootController < ApplicationController
  def index
    @currently_imprisoned_count = Prisoner.currently_imprisoned_count
    @one_year_ago_imprisoned_count = Prisoner.imprisoned_count(1.year.ago)

    if !File.exists?(Rails.public_path.join('imprisoned_count_timeline.json'))
      Prisoner.generate_imprisoned_count_timeline_json
    end

    gon.article_prisoner_counts_chart = Article.prisoner_counts_chart
  end
end