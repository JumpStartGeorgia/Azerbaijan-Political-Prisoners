class TranslatePrisons < ActiveRecord::Migration
  def self.up
    Prison.create_translation_table!(
      {
        name: :string,
        description: :text
      },
      migrate_data: true
    )

    remove_column :prisons, :name
    remove_column :prisons, :description
  end

  def self.down
  end
end
