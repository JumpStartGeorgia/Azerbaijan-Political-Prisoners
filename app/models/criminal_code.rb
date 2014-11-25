class CriminalCode < ActiveRecord::Base
  has_many :articles

  def name_with_model_name
    return name + ' Criminal Code'
  end
end
