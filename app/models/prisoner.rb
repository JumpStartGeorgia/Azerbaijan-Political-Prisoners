class Prisoner < ActiveRecord::Base
  has_many :incidents, inverse_of: :prisoner
  has_attached_file :portrait, :styles => { :medium => "200x200>" }, :default_url => ":style/missing.png"
  validates_attachment :portrait, content_type: { content_type: /\Aimage\/.*\Z/ }
  accepts_nested_attributes_for :incidents, :allow_destroy => true
  validates :name, presence: true

  def self.by_type(type)
    prisoners = []
    incidents = Incident.where(type: type)
    incidents.each do |incident|
      if !prisoners.include? incident.prisoner
        prisoners.append(incident.prisoner)
      end
    end

    return prisoners
  end
end
