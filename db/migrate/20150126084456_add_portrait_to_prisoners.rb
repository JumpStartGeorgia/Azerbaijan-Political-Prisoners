class AddPortraitToPrisoners < ActiveRecord::Migration
  def self.up
    add_attachment :prisoners, :portrait
  end

  def self.down
    remove_attachment :prisoners, :portrait
  end
end
