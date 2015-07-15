class PageSection < ActiveRecord::Base
  validates :name, presence: :true, uniqueness: :true
  validates :title, presence: :true
  translates :title, :content
end
