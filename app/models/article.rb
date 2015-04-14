class Article < ActiveRecord::Base
  belongs_to :criminal_code
  has_many :charges, dependent: :destroy
  has_many :incidents, through: :charges

  validates :number, :criminal_code, presence: true
  validates_uniqueness_of :number, :scope => :criminal_code, :message => "already exists for selected Criminal Code. Enter new Number or select different Criminal Code"

  def self.incident_counts_ordered(limit)
    primary_sql = 'select articles.id as article_id, articles.number as article_number, criminal_codes.name as criminal_code_name, count(*) as incident_count from incidents inner join charges on incidents.id = charges.incident_id inner join articles on charges.article_id = articles.id inner join criminal_codes on articles.criminal_code_id = criminal_codes.id group by articles.number order by count(*) desc'
    if limit.nil?
      return find_by_sql(primary_sql)
    else
      return find_by_sql(primary_sql + ' limit ' + limit.to_s)
    end
  end

  def self.article_incident_counts_chart
    article_info = []

    Article.incident_counts_ordered(10).each do |article|
      article_info.append({
          y: article[:incident_count],
          number: article[:article_number],
          link: Rails.application.routes.url_helpers.article_path(article[:article_id]),
          code: article[:criminal_code_name]
                                                })
    end

    return article_info
  end

  def self.generate_highest_incident_counts_chart_json
    dir_path = Rails.public_path.join("chart_data")
    json_path = dir_path.join("article_incident_counts_chart.json")
    # if folder path not exist, create it
    FileUtils.mkpath(dir_path) if !File.exists?(dir_path)
    File.open(json_path, "w") do |f|
      f.write(article_incident_counts_chart.to_json)
    end
  end
end
