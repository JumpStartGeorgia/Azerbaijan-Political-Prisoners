class Prisoner < ActiveRecord::Base
  after_commit :update_currently_imprisoned

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
    ids = currently_imprisoned_ids.map { |x| x.prisoner_id }
    where(id: ids)
  end

  def self.currently_imprisoned_count
    return currently_imprisoned_ids.size
  end

  def self.imprisoned_count(date)
    return imprisoned_ids(date).size
  end

  def self.imprisoned_counts_over_time
    all_incident_dates = find_by_sql("select date_of_arrest, date_of_release from incidents")
    imprisoned_incidents = []
    (Date.new(2007, 01, 01).to_date..Date.today).each do |date|
      imprisoned_incidents.append([Time.parse(date.to_s).utc.to_i*1000, all_incident_dates.select{ |x| x.date_of_arrest.to_date < date }.count])
    end

    return imprisoned_incidents
  end

  private

  def self.currently_imprisoned_ids
    return where(currently_imprisoned: true)
  end

  def update_currently_imprisoned
    latest_incident = self.incidents.order("date_of_arrest").last

    if !latest_incident.nil?
      if latest_incident.date_of_release.present?
        self.update_column(:currently_imprisoned, false)
      else
        self.update_column(:currently_imprisoned, true)
      end
    end
  end

  def self.imprisoned_ids(date)
    return find_by_sql("select prisoner_id from incidents where date_of_arrest < '" + date.strftime("%Y-%m-%d") + "' group by prisoner_id")
  end
end

