class CriminalCode < ActiveRecord::Base
  has_many :articles

  validates :name, presence: true, uniqueness: true

  # strip extra spaces before saving
  auto_strip_attributes :name

  def name_with_model_name
    name + ' Criminal Code'
  end
end
