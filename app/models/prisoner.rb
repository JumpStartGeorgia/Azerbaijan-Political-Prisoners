class Prisoner < ActiveRecord::Base
  has_many :incidents, inverse_of: :prisoner
  accepts_nested_attributes_for :incidents, :allow_destroy => true
  validates :name, presence: true
end
