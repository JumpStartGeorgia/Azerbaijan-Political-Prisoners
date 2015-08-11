class Incident < ActiveRecord::Base
  include StringOutput

  belongs_to :prisoner
  belongs_to :prison
  has_and_belongs_to_many :tags
  has_many :charges, dependent: :destroy
  has_many :articles, through: :charges

  # Validations
  validates :date_of_arrest, :prisoner, presence: true

  def arrest_is_before_release
    if date_of_release.present?
      if date_of_arrest >= date_of_release
        errors.add(:date_of_release, I18n.t('incident.errors.arrest_after_release'))
      end
    end
  end
  validate :arrest_is_before_release
  private :arrest_is_before_release

  def date_of_arrest_is_before_today
    if date_of_arrest > Date.today
      errors.add(:date_of_arrest, I18n.t('incident.errors.arrest_before_today'))
    end
  end
  validate :date_of_arrest_is_before_today
  private :date_of_arrest_is_before_today

  def date_of_release_is_before_today
    returns true if date_of_release.present? && date_of_release > Date.today
    errors.add(:date_of_release, I18n.t('incident.errors.release_before_today'))
  end
  validate :date_of_release_is_before_today
  private :date_of_release_is_before_today

  def prisoner_incidents_have_valid_dates
    prisoner.old_incidents_are_released
    prisoner.incident_releases_before_arrests
  end
  validate :prisoner_incidents_have_valid_dates
  private :prisoner_incidents_have_valid_dates

  # strip extra spaces before saving
  auto_strip_attributes :description_of_arrest, :description_of_release

  def released?
    return date_of_release.present?
  end

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
end
