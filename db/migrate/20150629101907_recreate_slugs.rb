class RecreateSlugs < ActiveRecord::Migration
  def up
    Article.transaction do
      Article.all.each do |article|
        puts '________________________________________________'
        puts "Updating article slug: #{article.slug}"
        puts ''
        article.slug = nil
        article.save!
        puts "New article slug: #{article.slug}"
        puts ''
      end
    end

    Prison.transaction do
      Prison.all.each do |prison|
        puts '________________________________________________'
        puts "Updating prison slug: #{prison.slug}"
        puts ''
        prison.slug = nil
        prison.save!
        puts "New prison slug: #{prison.slug}"
        puts ''
      end
    end

    Prisoner.transaction do
      Prisoner.all.each do |prisoner|
        puts '________________________________________________'
        puts "Updating prisoner slug: #{prisoner.slug}"
        puts ''
        prisoner.slug = nil
        prisoner.save!
        puts "New prisoner slug: #{prisoner.slug}"
        puts ''
      end
    end

    Tag.transaction do
      Tag.all.each do |tag|
        puts '________________________________________________'
        puts "Updating tag slug: #{tag.slug}"
        puts ''
        tag.slug = nil
        tag.save!
        puts "New tag slug: #{tag.slug}"
        puts ''
      end
    end
  end

  def down
  end
end
