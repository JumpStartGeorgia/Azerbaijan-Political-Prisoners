class AddNameIndexToRoles < ActiveRecord::Migration
  def change
    add_index :roles, :name
  end
end
