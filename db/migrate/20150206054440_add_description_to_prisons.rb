class AddDescriptionToPrisons < ActiveRecord::Migration
  def change
    add_column :prisons, :description, :text
  end
end
