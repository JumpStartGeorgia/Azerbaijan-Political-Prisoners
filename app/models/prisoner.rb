class Prisoner < ActiveRecord::Base
  has_many :incidents
  accepts_nested_attributes_for :incidents, :allow_destroy => true
  validates :name, presence: true

  validate :must_have_incident

  def must_have_incident
    if incidents.empty? or incidents.all? {|incident| incident.marked_for_destruction?}
      errors.add(:base, 'Must have at least one incident')
    end
  end
end
