class Incident < ActiveRecord::Base
  include StringOutput

  belongs_to :prisoner
  belongs_to :prison
  has_and_belongs_to_many :tags
  has_many :charges, dependent: :destroy
  has_many :articles, through: :charges

  validates :date_of_arrest, presence: true

  # strip extra spaces before saving
  auto_strip_attributes :description_of_arrest, :description_of_release

  def released?
    if date_of_release.nil?
      return false
    else
      return true
    end
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
