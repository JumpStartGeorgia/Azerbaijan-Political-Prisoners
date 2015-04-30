class Incident < ActiveRecord::Base
  belongs_to :prisoner
  belongs_to :prison
  has_and_belongs_to_many :tags
  has_many :charges, dependent: :destroy
  has_many :articles, through: :charges

  validates :date_of_arrest, presence: true

  def self.to_csv
    require 'csv'

    CSV.generate() do |csv|
      csv << ['Prisoner Name', 'Date of Arrest', 'Description of Arrest', 'Tags', 'Charges', 'Prison', 'Date of Release', 'Description of Release']
      all.includes(:prisoner).includes(:prison).includes(:tags).includes(:articles).each do |incident|
        csv << [
            incident.prisoner.name,
            incident.date_of_arrest,
            incident.description_of_arrest,
            incident.many_to_str(incident.tags, "name"),
            incident.many_to_str(incident.articles, "number"),
            incident.prison ? incident.prison.name : 'No Prison Listed',
            incident.date_of_release,
            incident.description_of_release
        ]
      end
    end
  end

  def many_to_str(objects, attribute)
    str = ""
    objects.each_with_index do |object, index|
      attribute_value = object[attribute]

      if objects.length - 1 == index
        str += attribute_value
      else
        str += attribute_value + '; '
      end
    end

    return str
  end
end
