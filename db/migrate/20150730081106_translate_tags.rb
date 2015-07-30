class TranslateTags < ActiveRecord::Migration
  def self.up
    Tag.create_translation_table!(
      {
        name: :string,
        description: :text
      },
      migrate_data: true
    )

    remove_column :tags, :name
    remove_column :tags, :description
  end

  def self.down
  end
end
