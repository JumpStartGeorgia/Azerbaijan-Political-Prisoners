class DropOldColumns < ActiveRecord::Migration
  def change
    remove_column :prisoners, :old_name
    remove_column :incidents, :old_description_of_arrest
    remove_column :incidents, :old_description_of_release
  end
end
