class CreateIncidents < ActiveRecord::Migration
  def change
    create_table :incidents do |t|
      t.references :prisoner, index: true
      t.string :date_of_arrest
      t.text :description_of_arrest
      t.references :prison, index: true
      t.references :type, index: true
      t.references :subtype, index: true
      t.string :date_of_release
      t.text :description_of_release

      t.timestamps
    end
  end
end
