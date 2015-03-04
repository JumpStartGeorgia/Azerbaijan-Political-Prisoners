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
    arrest_counts_by_day = self.arrest_counts_by_day
    timeline_starting_date = Date.new(2007,01,01).to_date
    dates_and_counts = []
    imprisoned_count = 0
    arrest_counts_by_day_within_timeline_period = []

    # Deal with arrests before starting date of timeline
    arrest_counts_by_day.each_with_index do |arrest_day_and_count, index|
      if Date.new(arrest_day_and_count[:year].to_i, arrest_day_and_count[:month].to_i, arrest_day_and_count[:day].to_i) < timeline_starting_date
        imprisoned_count += arrest_day_and_count["count(*)"].to_i
      else
        arrest_counts_by_day_within_timeline_period = arrest_counts_by_day.slice(index, arrest_counts_by_day.size)
        break
      end
    end

    # Iterate through all days in timeline. If there were arrests on a certain day, increase the imprisoned count for that day and all following days by that number of arrests
    (timeline_starting_date..Date.today).each do |date|
      arrest_day_and_count = arrest_counts_by_day_within_timeline_period[0]
      arrest_day = arrest_day_and_count.nil? ? nil : Date.new(arrest_day_and_count[:year].to_i, arrest_day_and_count[:month].to_i, arrest_day_and_count[:day].to_i)

      if arrest_day != nil && arrest_day == date
        imprisoned_count += arrest_day_and_count["count(*)"].to_i
        arrest_counts_by_day_within_timeline_period = arrest_counts_by_day_within_timeline_period.drop(1)
      end

      dates_and_counts.append([convert_date_to_utc(date), imprisoned_count])
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

  def self.arrest_counts_by_day
    return find_by_sql("select strftime('%Y', date_of_arrest) as year, strftime('%m', date_of_arrest) as month, strftime('%d', date_of_arrest) as day, count(*) from incidents group by strftime('%Y', date_of_arrest), strftime('%m', date_of_arrest), strftime('%d', date_of_arrest) order by year, month, day;")
  end

  def self.imprisoned_ids(date)
    return find_by_sql("select prisoner_id from incidents where date_of_arrest < '" + date.strftime("%Y-%m-%d") + "' group by prisoner_id")
  end
end

