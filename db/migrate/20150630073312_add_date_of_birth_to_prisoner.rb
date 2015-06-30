class AddDateOfBirthToPrisoner < ActiveRecord::Migration
  def change
    add_column :prisoners, :date_of_birth, :date
  end
end
