class Incident < ActiveRecord::Base
  include StringOutput

  belongs_to :prisoner
  belongs_to :prison
  has_and_belongs_to_many :tags
  has_many :charges, dependent: :destroy
  has_many :articles, through: :charges

  ################################################################
  ######################## Validations ###########################

  validates :date_of_arrest, :prisoner, presence: true

  def arrest_is_before_today?
    return if date_of_arrest.blank?
    return true if date_of_arrest <= Date.today

    errors.add(:date_of_arrest, I18n.t('incident.errors.arrest_after_today'))
  end
  validate :arrest_is_before_today?
  private :arrest_is_before_today?

  def release_is_before_today?
    return if date_of_release.blank?
    return true if date_of_release <= Date.today

    errors.add(:date_of_release, I18n.t('incident.errors.release_after_today'))
  end
  validate :release_is_before_today?
  private :release_is_before_today?

  def release_is_after_arrest?
    return if date_of_arrest.blank?
    return if date_of_release.blank?
    return true if date_of_release >= date_of_arrest

    errors.add(:date_of_release, I18n.t('incident.errors.arrest_after_release'))
  end
  validate :release_is_after_arrest?
  private :release_is_after_arrest?

  # If the new incident is the most recent incident, the previous incident
  # should be released, and the date of arrest should be after the previous
  # incident's date of release.
  def new_arrest_happened_after_previous_release?
    return if prisoner.blank?
    return if date_of_arrest.blank?
    return if only_incident_on_prisoner?
    return unless most_recent_incident_on_prisoner?

    previous_incident_edit_path = ActionController::Base.helpers.link_to 'earlier incident', Rails.application.routes.url_helpers.edit_prisoner_incident_path(I18n.locale, prisoner, previous_incident)

    if previous_incident.date_of_release.blank?
      errors.add(:date_of_arrest, "There is an #{previous_incident_edit_path} saved to #{prisoner.name} with no date of release. Either change the current incident's date of arrest to before the earlier incident's date of arrest (#{previous_incident.date_of_arrest}), or add a date of release to the earlier incident.")
    else
      if date_of_arrest < previous_incident.date_of_release
        errors.add(:date_of_arrest, "There is an #{previous_incident_edit_path} saved to #{prisoner.name} with a date of release (#{previous_incident.date_of_release}) after the current incident's date of arrest. Change the dates so they are in chronological order.")
      end
    end
  end
  validate :new_arrest_happened_after_previous_release?
  private :new_arrest_happened_after_previous_release?

  # If the new incident is not the most recent incident, then it should be
  # released, and the release date should be before the subsequent
  # incident's date of arrest.
  def released_before_subsequent_incident?
    return if prisoner.blank?
    return if date_of_arrest.blank?
    return if only_incident_on_prisoner?
    return if most_recent_incident_on_prisoner?

    subsequent_incident_edit_path = ActionController::Base.helpers.link_to 'later incident', Rails.application.routes.url_helpers.edit_prisoner_incident_path(I18n.locale, prisoner, subsequent_incident)

    if date_of_release.blank?
      errors.add(:date_of_release, "There is a #{subsequent_incident_edit_path} saved to #{prisoner.name}. Either add a date of release to the current incident, or change the order of the arrest dates on the incidents.")
    else
      if date_of_release > subsequent_incident.date_of_arrest
        errors.add(:date_of_release, "There is a #{subsequent_incident_edit_path} saved to #{prisoner.name} with a date of arrest before the current incident's date of release. Change the dates so they are in chronological order.")
      end
    end
  end
  validate :released_before_subsequent_incident?
  private :released_before_subsequent_incident?

  #########################################################################
  ###### Functions comparing incident to other incidents on prisoner ######

  # Get previous incident from chronologically ordered prisoner incidents
  def previous_incident
    prisoner
      .incidents
      .where('date_of_arrest < ?', date_of_arrest)
      .order(date_of_arrest: :asc)
      .last
  end

  # Get subsequent incident from chronoligically ordered prisoner incidents
  def subsequent_incident
    prisoner
      .incidents
      .where('date_of_arrest > ?', date_of_arrest)
      .order(date_of_arrest: :asc)
      .first
  end

  # Returns true if there are no other saved incidents on prisoner
  def only_incident_on_prisoner?
    prisoner
      .incidents
      .where.not(id: id)
      .size === 0
  end

  # Returns true if current incident has last prisoner date of arrest
  def most_recent_incident_on_prisoner?
    prisoner
      .incidents
      .where('date_of_arrest > ?', date_of_arrest)
      .size === 0
  end

  ##################################################################
  ######################## CSV Format ##############################

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << [
        I18n.t('activerecord.attributes.prisoner.name'),
        I18n.t('activerecord.attributes.incident.date_of_arrest'),
        I18n.t('activerecord.attributes.incident.description_of_arrest'),
        I18n.t('activerecord.attributes.incident.tags'),
        I18n.t('activerecord.models.charge', count: 999),
        I18n.t('activerecord.attributes.incident.prison'),
        I18n.t('activerecord.attributes.incident.date_of_release'),
        I18n.t('activerecord.attributes.incident.description_of_release')
      ]

      all.includes(:prisoner).includes(:prison)
        .includes(:tags).includes(:articles).each do |incident|
        csv << [
          incident.prisoner.name,
          incident.date_of_arrest,
          remove_tags(incident.description_of_arrest),
          incident.tags.map(&:name).join(', '),
          incident.articles.map(&:number).join(', '),
          incident.prison.present? ? incident.prison.name : I18n.t('shared.msgs.not_listed', obj: I18n.t('activerecord.models.prison', count: 1)),
          incident.date_of_release,
          remove_tags(incident.description_of_release)
        ]
      end
    end
  end

  ##################################################################

  # strip extra spaces before saving
  auto_strip_attributes :description_of_arrest, :description_of_release

  def released?
    return date_of_release.present?
  end
end
