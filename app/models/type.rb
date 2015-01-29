class Type < ActiveRecord::Base
  has_many :incidents
  has_many :subtypes

  validates :name, presence: true
  validates :name, uniqueness: true
end
