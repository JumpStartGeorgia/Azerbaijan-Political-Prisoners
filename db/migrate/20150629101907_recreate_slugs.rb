class RecreateSlugs < ActiveRecord::Migration
  def up
    Article.transaction do
      Article.all.each do |article|
        article.slug = nil
        article.save!
      end
    end

    Prison.transaction do
      Prison.all.each do |prison|
        prison.slug = nil
        prison.save!
      end
    end

    Prisoner.transaction do
      Prisoner.all.each do |prisoner|
        prisoner.slug = nil
        prisoner.save!
      end
    end

    Tag.transaction do
      Tag.all.each do |tag|
        tag.slug = nil
        tag.save!
      end
    end
  end

  def down
  end
end
