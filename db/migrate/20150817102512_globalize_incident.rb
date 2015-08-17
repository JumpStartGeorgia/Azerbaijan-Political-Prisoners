class GlobalizeIncident < ActiveRecord::Migration
  def up
    Incident.create_translation_table!(
      {
        description_of_arrest: :text,
        description_of_release: :text
      },
      migrate_data: true
    )

    rename_column :incidents, :description_of_arrest, :old_description_of_arrest
    rename_column :incidents, :description_of_release, :old_description_of_release
  end

  def down
    drop_table :incident_translations

    rename_column :incidents, :old_description_of_arrest, :description_of_arrest
    rename_column :incidents, :old_description_of_release, :description_of_release
  end
end
