class Prisoner < ActiveRecord::Base
  after_commit :update_currently_imprisoned
  after_commit :delete_dependent_json

  has_many :incidents, inverse_of: :prisoner
  has_attached_file :portrait, :styles => { :medium => "200x200>" }, :default_url => ":style/missing.png"
  validates_attachment :portrait, content_type: { content_type: /\Aimage\/.*\Z/ }
  accepts_nested_attributes_for :incidents, :allow_destroy => true
  validates :name, presence: true
  validate :validate_all_incidents_released_except_last
  validate :validate_incident_dates

  # Callbacks

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

  def delete_dependent_json
    Prisoner.delete_bar_chart_json
  end

  def self.delete_bar_chart_json
    ["imprisoned_count_timeline", "article_incident_counts_chart", "prison_prisoner_count_chart"].each do |json_data|
      path = Rails.public_path.join("data/" + json_data + ".json")
      File.delete(path) if File.exists?(path)
    end
  end

  # Validations

  def validate_incident_dates
    if self.incidents.present?
      # Ensure dates are chronological
      self.incidents.each_with_index do |incident, index|
        if incident.date_of_release.present?
          if incident.date_of_arrest > incident.date_of_release
            errors.add(:incident_id, "Date of arrest cannot be after date of release")
          end

          next_incident = self.incidents[index + 1]
          if !next_incident.nil?
            if incident.date_of_release > next_incident.date_of_arrest
              errors.add(:incident_id, "Date of arrest must occur after date of release of previous incident")
            end
          end
        end
      end

      # Ensure last date occurs before today
      if self.incidents.last.date_of_release.present? && self.incidents.last.date_of_release > Date.today
        errors.add(:date_of_release, "The last incident's date of release must be before today")
      elsif self.incidents.last.date_of_arrest.present? && self.incidents.last.date_of_arrest > Date.today
        errors.add(:date_of_arrest, "The last incident's date of arrest must be before today")
      end
    end
  end

  def validate_all_incidents_released_except_last
    if self.incidents.present?
      all_incidents_but_last = self.incidents.slice(0, incidents.size - 1)
      all_incidents_but_last.each do |incident|
        if !incident.date_of_release.present?
          errors.add(:prisoner_id, ": All incidents but the last must have dates of release")
        end
      end
    end
  end

  # Get prisoner by attribute

  def self.by_tag(tag_id)
    return Prisoner.joins(:incidents => :tags).where(tags:{id: tag_id})
  end

  def self.by_prison(prison_id)
    return Prisoner.joins(:incidents).where(incidents:{prison_id: prison_id})
  end

  def self.by_article(article_id)
    return Prisoner.joins(:incidents => :charges).where(charges:{article_id: article_id})
  end

  # Get prisoners by whether they are imprisoned or were imprisoned on a certain date

  def self.currently_imprisoned_count
    return currently_imprisoned_ids.size
  end

  def self.currently_imprisoned_ids
    return where(currently_imprisoned: true).select("id").map { |x| x.id }
  end

  def self.imprisoned_count(date)
    return imprisoned_ids(date).size
  end

  def self.imprisoned_ids(date)
    date_formatted = date.strftime("%Y-%m-%d")
    sql = "select prisoner_id from incidents where date_of_arrest < '" + date_formatted + "' and (date_of_release > '" + date_formatted + "' or date_of_release is null) group by prisoner_id"
    return find_by_sql(sql).map { |x| x.attributes["prisoner_id"] }
  end

  # Imprisoned count timeline

  def self.generate_imprisoned_count_timeline_json
    dir_path = Rails.public_path.join("data")
    json_path = dir_path.join("imprisoned_count_timeline.json")
    # if folder path not exist, create it
    FileUtils.mkpath(dir_path) if !File.exists?(dir_path)
    File.open(json_path, "w") do |f|
      f.write(imprisoned_counts_from_date_to_date(Date.new(2007,01,01), Date.today).to_json)
    end
  end

  def self.imprisoned_counts_from_date_to_date(starting_date, ending_date)
    imprisoned_count = 0

    all_arrest_counts_by_day = arrest_counts_by_day
    arrest_counts_by_day_within_timeline = []

    # Add number of arrests before starting date of timeline to prisoner count
    all_arrest_counts_by_day.each_with_index do |arrest_day_and_count, index|
      if create_date_from_hash(arrest_day_and_count) < starting_date
        imprisoned_count += arrest_day_and_count["count(*)"].to_i
      else
        arrest_counts_by_day_within_timeline = all_arrest_counts_by_day.slice(index, all_arrest_counts_by_day.size)
        break
      end
    end

    all_release_counts_by_day = release_counts_by_day
    release_counts_by_day_within_timeline = []

    # Subtract number of arrests before starting date of timeline to prisoner count
    all_release_counts_by_day.each_with_index do |release_day_and_count, index|
      if create_date_from_hash(release_day_and_count) < starting_date
        imprisoned_count -= release_day_and_count["count(*)"].to_i
      else
        release_counts_by_day_within_timeline = all_release_counts_by_day.slice(index, all_release_counts_by_day.size)
        break
      end
    end

    dates_and_counts = []

    # Iterate through all days in timeline.
    (starting_date..ending_date).each do |date|
      # If there are arrests on a certain day, increase the imprisoned count for that day and all following days by that number.
      if arrest_counts_by_day_within_timeline.size > 0
        arrest_day_and_count = arrest_counts_by_day_within_timeline[0]

        if create_date_from_hash(arrest_day_and_count) == date
          imprisoned_count += arrest_day_and_count["count(*)"].to_i
          arrest_counts_by_day_within_timeline = arrest_counts_by_day_within_timeline.drop(1)
        end
      end

      # If there are releases on a certain day, decrease the imprisoned count for that day and all following days by that number.
      if release_counts_by_day_within_timeline.size > 0
        release_day_and_count = release_counts_by_day_within_timeline[0]

        if create_date_from_hash(release_day_and_count) == date
          imprisoned_count -= release_day_and_count["count(*)"].to_i
          release_counts_by_day_within_timeline = release_counts_by_day_within_timeline.drop(1)
        end
      end

      dates_and_counts.append([convert_date_to_utc(date), imprisoned_count])
    end

    return dates_and_counts
  end

  def self.arrest_counts_by_day
    return find_by_sql("select year(date_of_arrest) as year, month(date_of_arrest) as month, day(date_of_arrest) as day, count(*) from incidents group by year, month, day order by year, month, day")
  end

  def self.release_counts_by_day
    release_counts_by_day = find_by_sql("select year(date_of_release) as year, month(date_of_release) as month, day(date_of_release) as day, count(*) from incidents group by year, month, day order by year, month, day")

    # If one or more incidents have no dates of release, then the first item in the array will have nil year, nil month and nil day. If that is the case, drop the first item
    release_counts_by_day = release_counts_by_day.size > 0 && release_counts_by_day[0][:year].nil? ? release_counts_by_day.drop(1) : release_counts_by_day
    return release_counts_by_day
  end

  def self.create_date_from_hash hash
    return Date.new(hash[:year].to_i, hash[:month].to_i, hash[:day].to_i)
  end

  def self.convert_date_to_utc date
    Time.parse(date.to_s).utc.to_i*1000
  end

  private :update_currently_imprisoned, :delete_dependent_json, :validate_incident_dates, :validate_all_incidents_released_except_last
  private_class_method :arrest_counts_by_day, :release_counts_by_day, :create_date_from_hash
end

