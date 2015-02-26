class AddDateOfArrestIndexToIncidents < ActiveRecord::Migration
  def change
    add_index :incidents, :date_of_arrest
  end
end
