class TranslateArticles < ActiveRecord::Migration
  def self.up
    Article.create_translation_table!(
      {
        description: :text
      },
      migrate_data: true
    )

    remove_column :articles, :description
  end

  def self.down
  end
end
