class Type < ActiveRecord::Base
  has_many :incidents

  validates :name, presence: true
  validates :name, uniqueness: true
end
