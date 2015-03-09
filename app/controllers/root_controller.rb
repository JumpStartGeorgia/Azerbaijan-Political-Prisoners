class RootController < ApplicationController
  def index
    @currently_imprisoned_count = Prisoner.currently_imprisoned_count
    @one_year_ago_imprisoned_count = Prisoner.imprisoned_count(1.year.ago)

    if !File.exists?(Rails.public_path.join('imprisoned_count_timeline.json'))
      Prisoner.generate_imprisoned_count_timeline_json
    end

    prisoner_counts = Article.prisoner_counts(10)

    gon.article_numbers = prisoner_counts[:article_numbers]
    gon.data = []

    (0..(prisoner_counts[:article_prisoner_counts].size - 1)).each do |i|
      gon.data.append([prisoner_counts[:article_criminal_codes][i], prisoner_counts[:article_prisoner_counts][i]])
    end
    gon.article_criminal_codes = prisoner_counts[:article_criminal_codes]
    gon.article_prisoner_counts = prisoner_counts[:article_prisoner_counts]
  end
end