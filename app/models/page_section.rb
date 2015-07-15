class PageSection < ActiveRecord::Base
  validates :name, presence: :true, uniqueness: :true
  translates :label, :content
end
