class ChangeGenderColumnToGenderId < ActiveRecord::Migration
  def up
    rename_column :prisoners, :gender, :gender_id
  end

  def down
  end
end
