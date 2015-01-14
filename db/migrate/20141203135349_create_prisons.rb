class CreatePrisons < ActiveRecord::Migration
  def change
    create_table :prisons do |t|
      t.string :name

      t.timestamps
    end
  end
end
