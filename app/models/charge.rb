class Charge < ActiveRecord::Base
    has_and_belongs_to_many :incident, dependent: :destroy
end
