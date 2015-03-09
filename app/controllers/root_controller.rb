class RootController < ApplicationController
  def index
    @currently_imprisoned_count = Prisoner.currently_imprisoned_count
    @one_year_ago_imprisoned_count = Prisoner.imprisoned_count(1.year.ago)

    if !File.exists?(Rails.public_path.join('imprisoned_count_timeline.json'))
      Prisoner.generate_imprisoned_count_timeline_json
    end

    articles_prisoner_counts = Article.prisoner_counts

    gon.categories = articles_prisoner_counts[:categories]
    gon.data = articles_prisoner_counts[:data]
  end
end