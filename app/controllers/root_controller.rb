class RootController < ApplicationController
  def index
    @currently_imprisoned_count = Prisoner.currently_imprisoned_count
    @one_year_ago_imprisoned_count = Prisoner.imprisoned_count(1.year.ago)

    gon.imprisoned_counts_over_time = Prisoner.imprisoned_counts_from_date_to_today Date.new(2007, 01, 01)
  end
end