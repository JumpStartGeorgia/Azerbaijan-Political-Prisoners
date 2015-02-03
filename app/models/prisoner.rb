class Prisoner < ActiveRecord::Base
  has_many :incidents, inverse_of: :prisoner
  has_attached_file :portrait, :styles => { :medium => "200x200>" }, :default_url => ":style/missing.png"
  validates_attachment :portrait, content_type: { content_type: /\Aimage\/.*\Z/ }
  accepts_nested_attributes_for :incidents, :allow_destroy => true
  validates :name, presence: true

  def self.by_type(type_id)
    return Prisoner.joins(:incidents).where(incidents:{type_id: type_id})
  end

  def self.by_subtype(subtype_id)
    return Prisoner.joins(:incidents).where(incidents:{subtype_id: subtype_id})
  end

  def self.by_tag(tag_id)
    return Prisoner.joins(:incidents => :tags).where(tags:{id: tag_id})
  end

  def self.by_prison(prison_id)
    return Prisoner.joins(:incidents).where(incidents:{prison_id: prison_id})
  end

  def self.by_article(article_id)
    return Prisoner.joins(:incidents => :charges).where(charges:{article_id: article_id})
  end
end

