class CreateCriminalCodes < ActiveRecord::Migration
  def change
    create_table :criminal_codes do |t|
      t.string :name

      t.timestamps
    end
  end
end
