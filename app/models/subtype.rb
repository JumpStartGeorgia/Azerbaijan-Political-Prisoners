class Subtype < ActiveRecord::Base
  belongs_to :type

  validates :name, :type, presence: true
  validates_uniqueness_of :name, :scope => :type
end
