class RootController < ApplicationController
  def index
    @currently_imprisoned_number = Prisoner.currently_imprisoned_count
  end
end