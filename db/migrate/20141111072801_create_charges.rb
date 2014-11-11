class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.references :incident, index: true
      t.references :article, index: true

      t.timestamps
    end
  end
end
