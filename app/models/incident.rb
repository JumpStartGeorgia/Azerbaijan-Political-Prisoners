class Incident < ActiveRecord::Base
  belongs_to :prisoner
  belongs_to :prison
  belongs_to :type
  belongs_to :subtype
  has_and_belongs_to_many :tags
  has_many :charges, dependent: :destroy
  has_many :articles, through: :charges

  validates :prisoner_id, :date_of_arrest, :type_id, presence: true
end
