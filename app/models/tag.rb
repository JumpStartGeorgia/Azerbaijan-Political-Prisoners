class Tag < ActiveRecord::Base
  extend FriendlyId

  has_and_belongs_to_many :incidents
  validates :name, presence: true, uniqueness: true

  # strip extra spaces before saving
  auto_strip_attributes :name, :description

  # permalink
  friendly_id :name, use: :history

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << %w(Name Description)
      all.each do |tag|
        csv << [tag.name, tag.description]
      end
    end
  end
end
