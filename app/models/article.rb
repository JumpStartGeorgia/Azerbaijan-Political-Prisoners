class Article < ActiveRecord::Base
  belongs_to :criminal_code
  has_many :charges, dependent: :destroy
  has_many :incidents, through: :charges

  validates :number, :criminal_code, presence: true
  validates_uniqueness_of :number, :scope => :criminal_code, :message => "already exists for selected Criminal Code. Enter new Number or select different Criminal Code"

  def self.prisoner_counts(limit)
    if limit.nil?
      articles = find_by_sql('select articles.number, criminal_codes.name, count(*) from incidents inner join charges on incidents.id = charges.incident_id inner join articles on charges.article_id = articles.id inner join criminal_codes on articles.criminal_code_id = criminal_codes.id group by articles.number order by count(*) desc')
    else
      articles = find_by_sql('select articles.number, criminal_codes.name as criminal_code_name, count(*) from incidents inner join charges on incidents.id = charges.incident_id inner join articles on charges.article_id = articles.id inner join criminal_codes on articles.criminal_code_id = criminal_codes.id group by articles.number order by count(*) desc limit ' + limit.to_s)
    end

    data = {article_numbers: [], article_criminal_codes: [], article_prisoner_counts: []}

    articles.each do |article|
      data[:article_numbers].append(article[:number])
      data[:article_criminal_codes].append(article[:criminal_code_name])
      data[:article_prisoner_counts].append(article["count(*)"])
    end

    return data
  end

end
