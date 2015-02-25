class RootController < ApplicationController
  def index
    @currently_imprisoned_number = Prisoner.all_currently_imprisoned.size
  end
end