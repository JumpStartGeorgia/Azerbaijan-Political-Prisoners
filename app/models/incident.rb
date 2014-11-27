class Incident < ActiveRecord::Base
  belongs_to :prisoner
  belongs_to :prison
  belongs_to :type
  belongs_to :subtype
  has_many :charges
  has_many :articles, through: :charges

  validates :prisoner, :date_of_arrest, :prison, :type, presence: true
end
