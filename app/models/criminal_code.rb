class CriminalCode < ActiveRecord::Base
  has_many :articles

  validates :name, presence: true

  def name_with_model_name
    return name + ' Criminal Code'
  end
end
