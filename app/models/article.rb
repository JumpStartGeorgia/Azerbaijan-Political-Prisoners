# An official article of law
class Article < ActiveRecord::Base
  include StringOutput
  extend FriendlyId

  belongs_to :criminal_code
  has_many :charges, dependent: :destroy
  has_many :incidents, through: :charges

  # strip extra spaces before saving
  auto_strip_attributes :number, :description

  translates :description, fallbacks_for_empty_translations: true
  # Allows reference of specific translations, i.e. post.title_az
  # or post.title_en
  globalize_accessors

  validates :number, :criminal_code, presence: true
  validates_uniqueness_of :number,
                          scope: :criminal_code,
                          message: I18n.t('article.errors.already_exists_for_criminal_code')

  # permalink
  friendly_id :number_and_code, use: :history
  def number_and_code
    "#{number}-in-#{criminal_code.name}-code"
  end

  def should_generate_new_friendly_id?
    number_changed? || criminal_code_id_changed? || slug.nil?
  end

  scope :with_criminal_code, -> { includes(:criminal_code) }

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << [
        I18n.t('activerecord.attributes.article.number'),
        I18n.t('activerecord.attributes.article.criminal_code'),
        I18n.t('activerecord.attributes.article.description')
      ]

      all.includes(:criminal_code)
        .order(criminal_code_id: :asc, number: :asc).each do |article|
        csv << [article.number,
                article.criminal_code.name,
                remove_tags(article.description)]
      end
    end
  end

  ############################################################
  ############ Article Charge Counts Chart ###################

  def self.summary(article_number, charge_count, code_name, desc)
    I18n.t('article.incident_counts_chart.summary',
           article_number: "<strong>##{article_number}</strong>",
           code_name: code_name,
           code_label: I18n.t('activerecord.models.criminal_code',
                              count: 1),
           number_of_incidents: "<strong>#{charge_count}</strong>",
           article_desc: desc)
  end

  def self.incident_counts_chart_data(limit = nil)
    # Get number of charges per article
    counts = Charge.limit(limit).group(:article_id).order('count_all desc').count

    # Get articles with criminal codes and translations. By using preload
    # instead of joins, further sql queries are not necessary to retreive the
    # translations
    articles = Article.preload(criminal_code: :translations)

    # Merge article info with charge counts
    articles_data = []

    counts.keys.each do |article_id|
      article = articles.find { |art| art.id == article_id }
      charge_count = counts[article.id]

      articles_data.append(
        y: charge_count,
        number: article.number,
        link: "/#{I18n.locale}/articles/#{article.slug}",
        summary: summary(article.number,
                         charge_count,
                         article.criminal_code.name,
                         article.description)
      )
    end

    articles_data
  end

  def self.incident_counts_chart_text
    {
      explore_charges: I18n.t('article.incident_counts_chart.static_text.explore_charges'),
      title: I18n.t('article.incident_counts_chart.static_text.title'),
      x_axis_label: I18n.t('article.incident_counts_chart.static_text.x_axis_label'),
      y_axis_label: I18n.t('article.incident_counts_chart.static_text.y_axis_label'),
      articles_path: Rails.application.routes.url_helpers
        .articles_path(locale: I18n.locale),
      highcharts: I18n.t('highcharts')
    }
  end

  def self.incident_counts_chart
    chart_data = {
      data: incident_counts_chart_data(10),
      text: incident_counts_chart_text
    }
  end

  def self.generate_highest_incident_counts_chart_json
    dir_path = Rails.public_path.join('generated', 'json', I18n.locale.to_s)
    json_path = dir_path.join('article_incident_counts_chart.json')
    # if folder path not exist, create it
    FileUtils.mkpath(dir_path) unless File.exist?(dir_path)
    File.open(json_path, 'w') do |f|
      f.write(incident_counts_chart.to_json)
    end
  end

  def desc
    description.present? ? ActionController::Base.helpers.strip_tags(description) : I18n.t('article.errors.no_description')
  end

  # include the current prisoner count with the article
  def self.with_current_and_all_prisoner_count(article_id = nil)
    # this old query counts number of incidents, not people
    # sql = 'select a.*, if(i_current.count is null, 0, i_current.count) as
    # current_prisoner_count, if(i_all.count is null, 0, i_all.count) as
    # all_prisoner_count from articles as a left join (select article_id,
    # count(*) as count from charges group by article_id) as i_all on
    # i_all.article_id = a.id left join (select article_id, count(*) as
    # count from charges as c inner join incidents as i on i.id = c.incident_id
    # where i.date_of_release is null group by c.article_id) as i_current on i_
    # current.article_id = a.id'
    sql = 'select a.*, if(i_current.count is null, 0, i_current.count) as
    current_prisoner_count, if(i_all.count is null, 0, i_all.count)
    as all_prisoner_count  from articles as a  left join (select x.article_id,
    count(*) as count from (select c.article_id from charges as c  inner join
    incidents as i on i.id = c.incident_id  group by c.article_id,
    i.prisoner_id) as x group by x.article_id) as i_all on
    i_all.article_id = a.id  left join (select article_id, count(*)
    as count from charges as c inner join incidents as i on i.id = c.incident_id
    where i.date_of_release is null group by c.article_id) as
    i_current on i_current.article_id = a.id'
    sql << ' where a.id = ?' if article_id.present?
    find_by_sql([sql, article_id])
  end
end
