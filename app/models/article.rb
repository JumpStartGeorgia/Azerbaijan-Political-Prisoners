# An official article of law
class Article < ActiveRecord::Base
  include StringOutput
  extend FriendlyId

  belongs_to :criminal_code
  has_many :charges, dependent: :destroy
  has_many :incidents, through: :charges

  # strip extra spaces before saving
  auto_strip_attributes :number, :description

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
        I18n.t('activerecord.attributes.article.name'),
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

  def self.incident_counts_ordered(limit = nil)
    primary_sql = 'select articles.id as article_id, articles.slug as slug,
      articles.number as article_number,
      criminal_codes.name as criminal_code_name,
      articles.description as description,
      count(*) as incident_count from incidents
      inner join charges on incidents.id = charges.incident_id
      inner join articles on charges.article_id = articles.id
      inner join criminal_codes
      on articles.criminal_code_id = criminal_codes.id
      group by articles.number order by count(*) desc'

    if limit.nil?
      find_by_sql(primary_sql)
    else
      find_by_sql(primary_sql + ' limit ' + limit.to_s)
    end
  end

  def summary
    I18n.t('article.incident_counts_chart.summary',
           article_number: "<strong>##{article_number}</strong>",
           code_name: criminal_code_name,
           code_label: I18n.t('activerecord.models.criminal_code',
                              count: 1),
           number_of_incidents: "<strong>#{incident_count.to_s}</strong>",
           article_desc: desc)
  end

  def self.incident_counts_chart_data
    article_info = []

    Article.incident_counts_ordered(10).each do |article|
      article_info.append(y: article[:incident_count],
                          number: article[:article_number],
                          link: "/#{I18n.locale}/articles/#{article[:slug]}",
                          summary: article.summary)
    end

    article_info
  end

  def self.incident_counts_chart_text
    text = I18n.t('article.incident_counts_chart.static_text')
    text['articles_path'] = Rails.application.routes.url_helpers.
                              articles_path(locale: I18n.locale)
    text['highcharts'] = I18n.t('highcharts')
    text
  end

  def self.incident_counts_chart
    chart_data = {
      data: incident_counts_chart_data,
      text: incident_counts_chart_text
    }
  end

  def self.generate_highest_incident_counts_chart_json
    dir_path = Rails.public_path.join('generated', 'json')
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
