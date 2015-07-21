class PageSection < ActiveRecord::Base
  validates :name, presence: :true, uniqueness: :true
  translates :label, :content, :fallbacks_for_empty_translations => true
  globalize_accessors
end
