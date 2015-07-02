class RemoveSubtypeAndTypeColumnsFromIncidents < ActiveRecord::Migration
  def up
    remove_column :incidents, :type_id
    remove_column :incidents, :subtype_id
  end

  def down
  end
end
