class CreateChargesIncidents < ActiveRecord::Migration
  def change
    create_table :charges_incidents, id: false do |t|
        t.belongs_to :charge
        t.belongs_to :incident
    end
  end
end
