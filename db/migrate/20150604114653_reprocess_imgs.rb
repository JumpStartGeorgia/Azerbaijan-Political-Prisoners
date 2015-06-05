class ReprocessImgs < ActiveRecord::Migration
  def change
    Prisoner.all.each do |prisoner|
      if prisoner.portrait_file_name.present? && File.exists?(prisoner.portrait.path)
        puts "processing #{prisoner.name}"
        prisoner.portrait.reprocess! 
      end
    end
  end
end
