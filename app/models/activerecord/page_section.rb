class PageSection < ActiveRecord::Base
  validates :name, presence: :true, uniqueness: :true
  translates :label, :content, fallbacks_for_empty_translations: true
  # Allows reference of specific translations, i.e. post.title_az
  # or post.title_en
  globalize_accessors
end
