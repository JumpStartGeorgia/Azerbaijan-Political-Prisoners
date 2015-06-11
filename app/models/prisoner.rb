class Prisoner < ActiveRecord::Base
  extend FriendlyId

  has_many :incidents, inverse_of: :prisoner, dependent: :destroy
  has_attached_file :portrait,
  styles: { thumb: '150x150>', large: '150x200>' },
  default_url: 'missing/:style.png',
                    url: '/system/images/:class/:attachment/:id/:style/:basename.:extension',
  convert_options: {:large => "-resize 150x200 -gravity center -extent 150x200"}
  validates_attachment :portrait, content_type: { content_type: /\Aimage\/.*\Z/ }
  accepts_nested_attributes_for :incidents, allow_destroy: true
  validates :name, presence: true, uniqueness: true
  validate :validate_all_incidents_released_except_last
  validate :validate_incident_dates

  # permalink
  friendly_id :name, use: :history

  # pagination
  self.per_page = 10

  # fields to search for in a story
  scoped_search :on => [:name]
  scoped_search :in => :incidents, :on => [:date_of_arrest, :date_of_release, :description_of_arrest, :description_of_release]

  # SCOPES
  scope :with_meta_data, -> { includes(incidents: [:prison, :tags, :articles]) }
  scope :ordered, -> { order(:name) } 


  # CSV format

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << ['Name']
      all.each do |prisoner|
        csv << [prisoner.name]
      end
    end
  end

  # Callbacks

  after_commit :update_currently_imprisoned, on: [:create, :update]

  def update_currently_imprisoned
    latest_incident = incidents.order('date_of_arrest').last

    return false if latest_incident.nil?

    if latest_incident.date_of_release.present?
      update_column(:currently_imprisoned, false)
    else
      update_column(:currently_imprisoned, true)
    end
  end

  # Validations

  def validate_incident_dates
    if incidents.present?
      # Ensure dates are chronological
      incidents.each_with_index do |incident, index|
        if incident.date_of_release.present?
          if incident.date_of_arrest > incident.date_of_release
            errors.add(:incident_id, 'Date of arrest cannot be after date of release')
          end

          next_incident = incidents[index + 1]
          unless next_incident.nil?
            if incident.date_of_release > next_incident.date_of_arrest
              errors.add(:incident_id, 'Date of arrest must occur after date of release of previous incident')
            end
          end
        end
      end

      # Ensure last date occurs before today
      if incidents.last.date_of_release.present? && incidents.last.date_of_release > Date.today
        errors.add(:date_of_release, "The last incident's date of release must be before today")
      elsif incidents.last.date_of_arrest.present? && incidents.last.date_of_arrest > Date.today
        errors.add(:date_of_arrest, "The last incident's date of arrest must be before today")
      end
    end
  end

  def validate_all_incidents_released_except_last
    if incidents.present?
      all_incidents_but_last = incidents.slice(0, incidents.size - 1)
      all_incidents_but_last.each do |incident|
        unless incident.date_of_release.present?
          errors.add(:prisoner_id, ': All incidents but the last must have dates of release')
        end
      end
    end
  end

  # Get prisoner by attribute

  def self.by_tag(tag_id)
    Prisoner.joins(incidents: :tags).where(tags: { id: tag_id })
  end

  def self.by_prison(prison_id)
    Prisoner.joins(:incidents).where(incidents: { prison_id: prison_id })
  end

  def self.by_article(article_id)
    Prisoner.joins(incidents: :charges).where(charges: { article_id: article_id })
  end

  # Get prisoners by whether they are imprisoned or were imprisoned on a certain date

  def self.currently_imprisoned_count
    currently_imprisoned_ids.size
  end

  def self.currently_imprisoned_ids
    where(currently_imprisoned: true).select('id').map(&:id)
  end

  def self.imprisoned_count(date)
    imprisoned_ids(date).size
  end

  def self.imprisoned_ids(date)
    date_formatted = date.strftime('%Y-%m-%d')
    sql = "select prisoner_id from incidents where date_of_arrest < '" + date_formatted + "' and (date_of_release > '" + date_formatted + "' or date_of_release is null) group by prisoner_id"
    find_by_sql(sql).map { |x| x.attributes['prisoner_id'] }
  end

  # Length spent in prison

  def total_days_in_prison
    time = 0
    self.incidents.each do |inc|
      if inc.released?
        time += inc.date_of_release - inc.date_of_arrest
      else
        time += Date.today - inc.date_of_arrest
      end
    end

    time.numerator
  end

  # Imprisoned count timeline

  def self.generate_imprisoned_count_timeline_json
    dir_path = Rails.public_path.join('system', 'json')
    json_path = dir_path.join('imprisoned_count_timeline.json')
    # if folder path not exist, create it
    FileUtils.mkpath(dir_path) unless File.exist?(dir_path)
    File.open(json_path, 'w') do |f|
      f.write(imprisoned_counts_from_date_to_date(Date.new(2012, 01, 01), Date.today).to_json)
    end
  end

  def self.imprisoned_counts_from_date_to_date(starting_date, ending_date)
    imprisoned_count = 0

    all_arrest_counts_by_day = arrest_counts_by_day
    arrest_counts_by_day_within_timeline = []

    # Add number of arrests before starting date of timeline to prisoner count
    all_arrest_counts_by_day.each_with_index do |arrest_day_and_count, index|
      if create_date_from_hash(arrest_day_and_count) < starting_date
        imprisoned_count += arrest_day_and_count['count(*)'].to_i
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
        imprisoned_count -= release_day_and_count['count(*)'].to_i
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
          imprisoned_count += arrest_day_and_count['count(*)'].to_i
          arrest_counts_by_day_within_timeline = arrest_counts_by_day_within_timeline.drop(1)
        end
      end

      # If there are releases on a certain day, decrease the imprisoned count for that day and all following days by that number.
      if release_counts_by_day_within_timeline.size > 0
        release_day_and_count = release_counts_by_day_within_timeline[0]

        if create_date_from_hash(release_day_and_count) == date
          imprisoned_count -= release_day_and_count['count(*)'].to_i
          release_counts_by_day_within_timeline = release_counts_by_day_within_timeline.drop(1)
        end
      end

      dates_and_counts.append([convert_date_to_utc(date), imprisoned_count])
    end

    dates_and_counts
  end

  def self.arrest_counts_by_day
    find_by_sql('select year(date_of_arrest) as year, month(date_of_arrest) as month, day(date_of_arrest) as day, count(*) from incidents group by year, month, day order by year, month, day')
  end

  def self.release_counts_by_day
    release_counts_by_day = find_by_sql('select year(date_of_release) as year, month(date_of_release) as month, day(date_of_release) as day, count(*) from incidents group by year, month, day order by year, month, day')

    # If one or more incidents have no dates of release, then the first item in the array will have nil year, nil month and nil day. If that is the case, drop the first item
    release_counts_by_day = release_counts_by_day.size > 0 && release_counts_by_day[0][:year].nil? ? release_counts_by_day.drop(1) : release_counts_by_day
    release_counts_by_day
  end

  def self.create_date_from_hash(hash)
    Date.new(hash[:year].to_i, hash[:month].to_i, hash[:day].to_i)
  end

  def self.convert_date_to_utc(date)
    Time.parse(date.to_s).utc.to_i * 1000
  end

  def currently_imprisoned_status
    if self.currently_imprisoned
      'Currently<br/> Imprisoned'
    elsif self.currently_imprisoned == false
      'Released'
    else
      'No Arrest<br/> Information'
    end
  end


  private :update_currently_imprisoned, :validate_incident_dates, :validate_all_incidents_released_except_last
  private_class_method :arrest_counts_by_day, :release_counts_by_day, :create_date_from_hash
end
