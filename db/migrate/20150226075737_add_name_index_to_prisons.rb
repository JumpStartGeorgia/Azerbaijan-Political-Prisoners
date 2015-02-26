class AddNameIndexToPrisons < ActiveRecord::Migration
  def change
    add_index :prisons, :name
  end
end
