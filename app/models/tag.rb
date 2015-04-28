class Tag < ActiveRecord::Base
  has_and_belongs_to_many :incidents
  validates :name, presence: true, uniqueness: true

  def as_csv(options={})
    attributes.slice('name', 'description')
  end
end
