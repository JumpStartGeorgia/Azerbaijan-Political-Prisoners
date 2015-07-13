class CriminalCode < ActiveRecord::Base
  has_many :articles

  validates :name, presence: true, uniqueness: true

  # strip extra spaces before saving
  auto_strip_attributes :name

  # Recreates the article slugs in case criminal code name changed
  after_save :save_articles
  def save_articles
    articles.each do |article|
      article.slug = nil
      article.save!
    end
  end

  def name_with_model_name
    I18n.t('criminal_codes.show.title',
      code_model_name: I18n.t('activerecord.models.criminal_code', count: 1),
      code_name: name)
  end
end
