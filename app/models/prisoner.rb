class Prisoner < ActiveRecord::Base
  has_many :incidents, inverse_of: :prisoner
  #has_attached_file :portrait, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  has_attached_file :portrait
  validates_attachment_content_type :portrait, :content_type => /\Aimage\/.*\Z/
  accepts_nested_attributes_for :incidents, :allow_destroy => true
  validates :name, presence: true
end
