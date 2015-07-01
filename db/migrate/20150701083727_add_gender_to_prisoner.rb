class AddGenderToPrisoner < ActiveRecord::Migration
  def change
    add_column :prisoners, :gender, :integer, default: 2
    add_index :prisoners, :gender
  end
end
