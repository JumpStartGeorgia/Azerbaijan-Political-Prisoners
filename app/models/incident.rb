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
      csv << ['Date of Arrest']
      all.each do |incident|
        csv << [incident.date_of_arrest]
      end
    end
  end
end
