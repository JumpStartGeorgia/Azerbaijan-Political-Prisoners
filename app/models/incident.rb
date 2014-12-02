class Incident < ActiveRecord::Base
  belongs_to :prisoner
  belongs_to :prison
  belongs_to :type
  belongs_to :subtype
  has_many :charges, dependent: :destroy
  has_many :articles, through: :charges

  validates :prisoner_id, :date_of_arrest, :article_ids, :prison_id, :type_id, presence: true
  validate :check_validating

  def check_validating
    Rails.logger.debug('Validating Incident ——————————————————————————————————————————————————————————————— Validating Incident')
  end
end
