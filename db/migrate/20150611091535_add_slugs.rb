class AddSlugs < ActiveRecord::Migration
  def up
    add_column :articles, :slug, :string
    add_index :articles, :slug

    add_column :prisons, :slug, :string
    add_index :prisons, :slug

    add_column :tags, :slug, :string
    add_index :tags, :slug

    # slug is created when record is saved
    Article.transaction do
      Article.find_each(&:save)
      Prison.find_each(&:save)
      Tag.find_each(&:save)
    end
  end

  def down
    remove_index :articles, :slug
    remove_column :articles, :slug

    remove_index :prisons, :slug
    remove_column :prisons, :slug

    remove_index :tags, :slug
    remove_column :tags, :slug

    connection = ActiveRecord::Base.connection
    connection.execute("delete from friendly_id_slugs where sluggable_type in ('Article', 'Tag', 'Prison')")
  end
end
