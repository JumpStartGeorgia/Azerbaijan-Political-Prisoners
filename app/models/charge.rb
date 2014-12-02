class Charge < ActiveRecord::Base
  belongs_to :incident
  belongs_to :article

  validates :incident_id, :article_id, presence: true
  validates_associated :incident, :article
end
