class ReprocessImage < ActiveRecord::Migration
  def change
    Prisoner.all.each do |prisoner|
      if prisoner.portrait_file_name.present? && File.exist?(prisoner.portrait.path)
        puts "processing #{prisoner.name}"
        prisoner.portrait.reprocess!(:medium)
        prisoner.portrait.reprocess!
      end
    end
  end
end
