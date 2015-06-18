class AddPTagsToTagDescriptions < ActiveRecord::Migration
  def up
    Tag.transaction do
      Tag.all.each do |tag|
        puts '---------------------------------------------'
        puts "id = #{tag.id}"
        puts "desc = #{tag.description}"
        if tag.description.present? && !tag.description.start_with?('<p', '<P')
          puts '>>>>> has desc that does not start with p, applying simple format'
          tag.description = ActionController::Base.helpers.simple_format(tag.description)
          puts "new desc = #{tag.description}"
        end

        tag.save
      end
    end
  end

  def down
  end
end
