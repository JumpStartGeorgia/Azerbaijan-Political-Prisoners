class CreatePageSections < ActiveRecord::Migration
  def up
    create_table :page_sections do |t|
      t.string :name
      t.string :title
      t.text :content

      t.timestamps null: false
    end

    PageSection.create_translation_table! title: :string, content: :text
  end

  def down
    drop_table :page_sections
    PageSection.drop_translation_table!
  end
end
