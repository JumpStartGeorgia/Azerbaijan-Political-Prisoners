class Prisoner < ActiveRecord::Base
  extend FriendlyId

  has_many :incidents, inverse_of: :prisoner, dependent: :destroy
  has_attached_file :portrait,
                    styles: { thumb: '150x150>', large: '150x200>' },
                    default_url: 'missing/:style.png',
                    url: '/system/images/:class/:attachment/:id/:style/:basename.:extension',
                    convert_options: { large: '-resize 150x200 -gravity center -extent 150x200' }
  validates_attachment :portrait, content_type: { content_type: /\Aimage\/.*\Z/ }
  accepts_nested_attributes_for :incidents, allow_destroy: true
  validates :name, presence: true, uniqueness: true
  validates :gender_id, presence: true, inclusion: { in: [1, 2, 3] }

  # strip extra spaces before saving
  auto_strip_attributes :name

  # permalink
  friendly_id :name, use: :history

  def should_generate_new_friendly_id?
    name_changed? || slug.nil?
  end

  # pagination
  self.per_page = 10

  # fields to search for in a story
  scoped_search on: [:name]
  scoped_search in: :incidents, on: [:date_of_arrest, :date_of_release, :description_of_arrest, :description_of_release]

  # SCOPES
  scope :with_meta_data, -> { includes(incidents: [:prison, :tags, :articles]) }
  scope :ordered, -> { order(:name) }
  scope :ordered_date_of_arrest, -> { order('incidents.date_of_arrest desc') }

  # CSV format

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << [I18n.t('activerecord.attributes.prisoner.name')]
      all.each do |prisoner|
        csv << [prisoner.name]
      end
    end
  end

  # Callbacks


  def update_currently_imprisoned
    latest_incident = incidents.order('date_of_arrest').last

    return false if latest_incident.nil?

    if latest_incident.date_of_release.present?
      update_column(:currently_imprisoned, false)
    else
      update_column(:currently_imprisoned, true)
    end
  end
  after_commit :update_currently_imprisoned, on: [:create, :update]
  private :update_currently_imprisoned

  ################################################################
  ############ Validations called when incident saved ############

  # Valid if all incidents but the most recent are released
  def old_incidents_are_released?
    return true if incidents.blank?

    old_incidents = incidents.sort_by(&:date_of_arrest).slice(0, incidents.size - 1)
    old_incidents.each do |incident|
      if incident.date_of_release.blank?
        errors.add(:base, I18n.t('prisoner.errors.must_have_release'))
      end
    end
  end

  # Valid if each incident's release date is before the next incident's arrest
  def always_released_before_arrested?
    sorted_incidents = incidents.sort_by(&:date_of_arrest)

    sorted_incidents.each_with_index do |incident, index|
      if incident.date_of_release.present? && incident != sorted_incidents.last
        next_incident = sorted_incidents[index + 1]

        if incident.date_of_release > next_incident.date_of_arrest
          errors.add(:base, I18n.t('prisoner.errors.arrest_after_previous_release'))
        end
      end
    end
  end

  ################################################################
  # Get prisoner by attribute

  def self.by_tag(tag_id)
    Prisoner.joins(incidents: :tags).where(tags: { id: tag_id }).uniq
  end

  def self.by_prison(prison_id)
    Prisoner.joins(:incidents).where(incidents: { prison_id: prison_id }).uniq
  end

  def self.by_article(article_id)
    Prisoner.joins(incidents: :charges).where(charges: { article_id: article_id }).uniq
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

  # Attributes

  # Gender is stored in database as 1, 2, and 3, corresponding to
  # female, male and other.
  GENDER = {
    female: 1,
    male: 2,
    other: 3
  }

  def self.get_gender_id_from_key(key)
    GENDER[key]
  end

  def self.get_gender_key_from_id(id)
    GENDER.keys[GENDER.values.index(id)]
  end

  def gender
    Prisoner.get_gender_key_from_id(gender_id)
  end

  def age_in_years
    today = Date.today
    y = today.year - date_of_birth.year

    y -= 1 if
      date_of_birth.month > today.month ||
      (date_of_birth.month == today.month && date_of_birth.day > today.day)
    y
  end

  def total_days_in_prison
    time = 0
    incidents.each do |inc|
      if inc.released?
        time += inc.date_of_release - inc.date_of_arrest
      else
        time += Date.today - inc.date_of_arrest
      end
    end

    time.numerator
  end

  ############################################################
  ############### Imprisoned count timeline ###############

  def self.arrest_counts_by_day
    find_by_sql('select year(date_of_arrest) as year, month(date_of_arrest) as month, day(date_of_arrest) as day, count(*) from incidents group by year, month, day order by year, month, day')
  end
  private_class_method :arrest_counts_by_day

  def self.release_counts_by_day
    release_counts_by_day = find_by_sql('select year(date_of_release) as year, month(date_of_release) as month, day(date_of_release) as day, count(*) from incidents group by year, month, day order by year, month, day')

    # If one or more incidents have no dates of release, then the first item in the array will have nil year, nil month and nil day. If that is the case, drop the first item
    release_counts_by_day = release_counts_by_day.size > 0 && release_counts_by_day[0][:year].nil? ? release_counts_by_day.drop(1) : release_counts_by_day
    release_counts_by_day
  end
  private_class_method :release_counts_by_day

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

  def self.imprisoned_count_timeline_text
    {
      title: I18n.t('prisoner.imprisoned_count_timeline.title'),
      explore_prisoners: I18n.t('prisoner.imprisoned_count_timeline.explore_prisoners'),
      number_prisoners: I18n.t('prisoner.imprisoned_count_timeline.number_prisoners'),
      date_summary: I18n.t('prisoner.imprisoned_count_timeline.date_summary'),
      prisoners_path: Rails.application.routes.url_helpers.prisoners_path(locale: I18n.locale),
      highcharts: I18n.t('highcharts'),
      date_format: I18n.t('date.formats.full')
    }
  end

  def self.imprisoned_count_timeline
    {
      data: imprisoned_counts_from_date_to_date(Date.new(2012, 01, 01),
                                                Date.today),
      text: imprisoned_count_timeline_text
    }
  end

  def self.generate_imprisoned_count_timeline_json(imprisoned_count_timeline_path)
    # if folder path does not exist, create it
    FileUtils.mkdir_p(Pathname.new(File.dirname(imprisoned_count_timeline_path)))

    File.open(imprisoned_count_timeline_path, 'w') do |f|
      f.write(imprisoned_count_timeline.to_json)
    end
  end

  def self.imprisoned_count_timeline_json
    imprisoned_count_timeline_path =
      Rails.public_path.join('generated',
                             'json',
                             I18n.locale.to_s,
                             'imprisoned_count_timeline.json')

    unless File.exist?(imprisoned_count_timeline_path)
      generate_imprisoned_count_timeline_json(imprisoned_count_timeline_path)
    end

    return imprisoned_count_timeline_path
  end

  ############################################################

  def self.create_date_from_hash(hash)
    Date.new(hash[:year].to_i, hash[:month].to_i, hash[:day].to_i)
  end
  private_class_method :create_date_from_hash

  def self.convert_date_to_utc(date)
    Time.parse(date.to_s).utc.to_i * 1000
  end

  def currently_imprisoned_status
    if currently_imprisoned
      I18n.t('prisoner.currently_imprisoned')
    elsif currently_imprisoned == false
      I18n.t('prisoner.released')
    else
      I18n.t('prisoner.no_arrest_info')
    end
  end
end
