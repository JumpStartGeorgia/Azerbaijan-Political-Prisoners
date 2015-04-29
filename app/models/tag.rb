class Tag < ActiveRecord::Base
  has_and_belongs_to_many :incidents
  validates :name, presence: true, uniqueness: true

  def self.to_csv
    require 'csv'

    CSV.generate() do |csv|
      csv << ['Name', 'Description']
      all.each do |tag|
        csv << [tag.name, tag.description]
      end
    end
  end
end
