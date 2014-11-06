class CreateSubtypes < ActiveRecord::Migration
  def change
    create_table :subtypes do |t|
      t.string :name
      t.references :type, index: true
      t.text :description

      t.timestamps
    end
  end
end
