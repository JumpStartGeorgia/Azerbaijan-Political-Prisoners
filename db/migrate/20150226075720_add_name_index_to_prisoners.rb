class AddNameIndexToPrisoners < ActiveRecord::Migration
  def change
    add_index :prisoners, :name
  end
end
