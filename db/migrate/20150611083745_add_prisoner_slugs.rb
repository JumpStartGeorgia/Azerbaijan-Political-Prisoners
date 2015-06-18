class AddPrisonerSlugs < ActiveRecord::Migration
  def up
    add_column :prisoners, :slug, :string
    add_index :prisoners, :slug

    # slug is created when record is saved
    Prisoner.transaction do
      Prisoner.find_each(&:save)
    end
  end

  def down
    remove_index :prisoners, :slug
    remove_column :prisoners, :slug

    connection = ActiveRecord::Base.connection
    connection.execute("delete from friendly_id_slugs where sluggable_type='Prisoner'")
  end
end
