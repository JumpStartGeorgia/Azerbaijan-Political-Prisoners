class AddPTagsIncidentsDesc < ActiveRecord::Migration
  def up
    Incident.transaction do 
      Incident.all.each do |inc|
        puts "---------"
        puts "id = #{inc.id}"
        puts "desc of arrest = #{inc.description_of_arrest}"
        if inc.description_of_arrest.present? && !inc.description_of_arrest.start_with?('<p', '<P')
          puts ">>>>> has arrest desc that does not start with p, applying simple format"
          inc.description_of_arrest = ActionController::Base.helpers.simple_format(inc.description_of_arrest)
        end

        puts "----"

        puts "desc of release = #{inc.description_of_release}"
        if inc.description_of_release.present? && !inc.description_of_release.start_with?('<p', '<P')
          puts ">>>>> has release desc that does not start with p, applying simple format"
          inc.description_of_release = ActionController::Base.helpers.simple_format(inc.description_of_release)
        end

        inc.save
      end
    end
  end

  def down
    # do nothing
  end
end
