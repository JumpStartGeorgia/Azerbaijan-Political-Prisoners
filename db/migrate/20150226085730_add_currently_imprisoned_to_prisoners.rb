class AddCurrentlyImprisonedToPrisoners < ActiveRecord::Migration
  def change
    add_column :prisoners, :currently_imprisoned, :boolean
  end
end
