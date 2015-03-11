class Article < ActiveRecord::Base
  belongs_to :criminal_code
  has_many :charges, dependent: :destroy
  has_many :incidents, through: :charges

  validates :number, :criminal_code, presence: true
  validates_uniqueness_of :number, :scope => :criminal_code, :message => "already exists for selected Criminal Code. Enter new Number or select different Criminal Code"

  def self.incident_counts_ordered(limit)
    if limit.nil?
      articles = find_by_sql('select articles.number, criminal_codes.name, count(*) from incidents inner join charges on incidents.id = charges.incident_id inner join articles on charges.article_id = articles.id inner join criminal_codes on articles.criminal_code_id = criminal_codes.id group by articles.number order by count(*) desc')
    else
      articles = find_by_sql('select articles.number, criminal_codes.name as criminal_code_name, count(*) from incidents inner join charges on incidents.id = charges.incident_id inner join articles on charges.article_id = articles.id inner join criminal_codes on articles.criminal_code_id = criminal_codes.id group by articles.number order by count(*) desc limit ' + limit.to_s)
    end

    data = {
        article_numbers: [],
        article_criminal_codes: [],
        article_incident_counts: []
    }

    articles.each do |article|
      data[:article_numbers].append(article[:number])
      data[:article_criminal_codes].append(article[:criminal_code_name])
      data[:article_incident_counts].append(article["count(*)"])
    end

    return data
  end

  def self.highest_incident_counts_chart
    highest_incident_counts = Article.incident_counts_ordered(10)
    article_numbers_and_links = []
    highest_incident_counts[:article_numbers].each do |number|
      article_numbers_and_links.append({
                                           number: number,
                                           link: Rails.application.routes.url_helpers.article_path(Article.find_by_number(number).id)
                                       })
    end
    incident_counts_and_criminal_codes = []

    (0..(highest_incident_counts[:article_incident_counts].size - 1)).each do |i|
      incident_counts_and_criminal_codes.append({
                             y: highest_incident_counts[:article_incident_counts][i],
                             criminal_code: highest_incident_counts[:article_criminal_codes][i]
                         })
    end

    return {
        article_numbers_and_links: article_numbers_and_links,
        incident_counts_and_criminal_codes: incident_counts_and_criminal_codes
    }
  end

  def self.generate_highest_incident_counts_chart_json
    File.open(Rails.public_path.join("chart_data/highest_incident_counts_chart.json"), "w") do |f|
      f.write(highest_incident_counts_chart.to_json)
    end
  end
end
