class AddDateOfReleaseIndexToIncidents < ActiveRecord::Migration
  def change
    add_index :incidents, :date_of_release
  end
end
