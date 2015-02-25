class Prisoner < ActiveRecord::Base
  has_many :incidents, inverse_of: :prisoner
  has_attached_file :portrait, :styles => { :medium => "200x200>" }, :default_url => ":style/missing.png"
  validates_attachment :portrait, content_type: { content_type: /\Aimage\/.*\Z/ }
  accepts_nested_attributes_for :incidents, :allow_destroy => true
  validates :name, presence: true

  def self.by_tag(tag_id)
    return Prisoner.joins(:incidents => :tags).where(tags:{id: tag_id})
  end

  def self.by_prison(prison_id)
    return Prisoner.joins(:incidents).where(incidents:{prison_id: prison_id})
  end

  def self.by_article(article_id)
    return Prisoner.joins(:incidents => :charges).where(charges:{article_id: article_id})
  end

  def self.all_currently_imprisoned
    all_currently_imprisoned = []
    Prisoner.all.each do |prisoner|
      if prisoner.currently_imprisoned?
        all_currently_imprisoned.append(prisoner)
      end
    end
    return all_currently_imprisoned
  end

  def currently_imprisoned?
    latest_incident = self.incidents.order("date_of_arrest").last

    if !latest_incident.date_of_release.presence
      return true
    else
      return false
    end
  end
end

