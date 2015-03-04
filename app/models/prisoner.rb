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
    incidents = Incident.select(:date_of_arrest, :date_of_release, :id).map{ |x| [convert_date_to_utc(x.date_of_arrest), x.date_of_release.nil? ? nil : convert_date_to_utc(x.date_of_release)] }

    dates_and_counts = []
    (Date.new(2007, 01, 01).to_date..Date.today).each do |date|
      dates_and_counts.append([convert_date_to_utc(date), 0])
    end

    incidents.each do |incident|
      arrest_index = dates_and_counts.index{|date| date[0] == incident[0]}
      release_index = incident[1].nil? ? nil : dates_and_counts.index{|date| date[0] == incident[1]}

      if arrest_index.nil? # If prisoner was arrested before beginning date of timeline
        arrest_index = 0
      end

      if release_index.nil? # If prisoner has not been released yet
        release_index = dates_and_counts.size - 1
      end

      dates_and_counts.slice(arrest_index, release_index + 1).each do |date|
        date[1] += 1
      end
    end

    return dates_and_counts
  end

  private

  def self.convert_date_to_utc date
    Time.parse(date.to_s).utc.to_i*1000
  end

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

