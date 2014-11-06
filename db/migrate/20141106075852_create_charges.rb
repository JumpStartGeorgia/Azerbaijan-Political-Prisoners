class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.string :number
      t.string :criminal_code
      t.text :description

      t.timestamps
    end
  end
end
