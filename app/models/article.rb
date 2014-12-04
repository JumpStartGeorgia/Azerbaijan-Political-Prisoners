class Article < ActiveRecord::Base
  belongs_to :criminal_code
  has_many :charges
  has_many :incidents, through: :charges

  validates :number, presence: true
end
