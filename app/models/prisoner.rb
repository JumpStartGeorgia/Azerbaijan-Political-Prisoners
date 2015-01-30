class Prisoner < ActiveRecord::Base
  has_many :incidents, inverse_of: :prisoner
  has_attached_file :portrait, :styles => { :medium => "200x200>" }, :default_url => ":style/missing.png"
  validates_attachment :portrait, content_type: { content_type: /\Aimage\/.*\Z/ }
  accepts_nested_attributes_for :incidents, :allow_destroy => true
  validates :name, presence: true

  def self.by_type(type)
    return Prisoner.joins(:incidents).where(incidents:{type_id: type.id})
  end

  def self.by_subtype(subtype)
    return Prisoner.joins(:incidents).where(incidents:{subtype_id: subtype.id})
  end

  def self.by_prison(prison)
    return Prisoner.joins(:incidents).where(incidents:{prison_id: prison.id})
  end
end

