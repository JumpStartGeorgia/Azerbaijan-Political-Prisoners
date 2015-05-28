class CriminalCode < ActiveRecord::Base
  has_many :articles

  validates :name, presence: true, uniqueness: true

  def name_with_model_name
    name + ' Criminal Code'
  end
end
