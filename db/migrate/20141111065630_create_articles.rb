class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :number
      t.references :criminal_code, index: true
      t.text :description

      t.timestamps
    end
  end
end
