class Incident < ActiveRecord::Base
  belongs_to :prisoner
  belongs_to :prison
  belongs_to :type
  belongs_to :subtype
  has_and_belongs_to_many :charge, dependent: :destroy
end
