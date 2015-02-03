class CreateIncidentsTagsJoinTable < ActiveRecord::Migration
  def change
    create_table :incidents_tags, id: false do |t|
      t.integer :incident_id
      t.integer :tag_id
    end

    add_index :incidents_tags, :incident_id
    add_index :incidents_tags, :tag_id
  end
end
