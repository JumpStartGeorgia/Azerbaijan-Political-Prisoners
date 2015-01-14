class Subtype < ActiveRecord::Base
  belongs_to :type

  validates :name, :type, presence: true
end
