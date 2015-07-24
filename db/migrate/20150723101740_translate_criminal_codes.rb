class TranslateCriminalCodes < ActiveRecord::Migration
  def self.up
    CriminalCode.create_translation_table!(
      { name: :string },
      migrate_data: true
    )

    remove_column :criminal_codes, :name
  end

  def self.down
  end
end
