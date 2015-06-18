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
                          message: 'already exists for selected Criminal Code.
                            Enter new Number or select different Criminal Code'

  # permalink
  friendly_id :slug_candidates, use: :history
  def slug_candidates
    [
      [criminal_code.name, :number]
    ]
  end

  scope :with_criminal_code, -> { includes(:criminal_code) }

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << ['Number', 'Criminal Code', 'Description']
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

  def self.article_incident_counts_chart
    article_info = []

    Article.incident_counts_ordered(10).each do |article|
      article_info.append(y: article[:incident_count],
                          number: article[:article_number],
                          link: "/#{I18n.locale}/articles/#{article[:slug]}",
                          code: article[:criminal_code_name],
                          description: article[:description])
    end

    article_info
  end

  def self.generate_highest_incident_counts_chart_json
    dir_path = Rails.public_path.join('system', 'json')
    json_path = dir_path.join('article_incident_counts_chart.json')
    # if folder path not exist, create it
    FileUtils.mkpath(dir_path) unless File.exist?(dir_path)
    File.open(json_path, 'w') do |f|
      f.write(article_incident_counts_chart.to_json)
    end
  end

  def desc
    description.present? ? ActionController::Base.helpers.strip_tags(description) : 'No description available'
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
