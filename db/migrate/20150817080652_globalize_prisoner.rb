class GlobalizePrisoner < ActiveRecord::Migration
  def up
    Prisoner.create_translation_table!(
      {
        name: :string
      },
      migrate_data: true
    )

    rename_column :prisoners, :name, :old_name
  end

  def down
    drop_table :prisoner_translations
    rename_column :prisoners, :old_name, :name
  end
end
