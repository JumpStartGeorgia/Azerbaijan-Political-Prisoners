class Prison < ActiveRecord::Base
  include StringOutput
  extend FriendlyId

  has_many :incidents, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  # strip extra spaces before saving
  auto_strip_attributes :name, :description

  # permalink
  friendly_id :name, use: :history

  def should_generate_new_friendly_id?
    name_changed? || slug.nil?
  end

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << %w(Name Description)
      all.each do |prison|
        csv << [prison.name, remove_tags(prison.description)]
      end
    end
  end

  def self.generate_prison_prisoner_count_chart_json
    dir_path = Rails.public_path.join('system', 'json')
    json_path = dir_path.join('prison_prisoner_count_chart.json')
    # if folder path not exist, create it
    FileUtils.mkpath(dir_path) unless File.exist?(dir_path)
    File.open(json_path, 'w') do |f|
      f.write(current_prisoner_counts.to_json)
    end
  end

  # include the current prisoner count with the prisons
  def self.with_current_and_all_prisoner_count(prison_id = nil)
    # this old query counts number of incidents, not people
    # sql = 'select p.*, if(i_current.count is null, 0, i_current.count) as current_prisoner_count, if(i_all.count is null, 0, i_all.count) as all_prisoner_count from prisons as p left join (select prison_id, count(*) as count from incidents group by prison_id) as i_all on i_all.prison_id = p.id left join (select prison_id, count(*) as count from incidents where date_of_release is null group by prison_id) as i_current on i_current.prison_id = p.id'
    sql = 'select p.*, if(i_current.count is null, 0, i_current.count) as current_prisoner_count, if(i_all.count is null, 0, i_all.count) as all_prisoner_count  from prisons as p  left join (select x.prison_id, count(*) as count from  (select prison_id from incidents group by prison_id,prisoner_id) as x group by x.prison_id) as i_all on i_all.prison_id = p.id  left join (select prison_id, count(*) as count from incidents where date_of_release is null group by prison_id) as i_current on i_current.prison_id = p.id'
    sql << ' where p.id = ?' if prison_id.present?
    find_by_sql([sql, prison_id])
  end

  private

  def self.current_prisoner_counts
    prisons = []

    current_prisoner_counts_sql(10).each do |prison_prisoner_count|
      prisons.append(y: prison_prisoner_count[:prisoner_count],
                     name: prison_prisoner_count[:prison_name],
                     link: "/#{I18n.locale}/prisons/#{prison_prisoner_count[:slug]}")
    end

    prisons
  end

  def self.current_prisoner_counts_sql(limit = nil)
    primary_sql = 'select prisons.id as prison_id, prisons.slug as slug, prisons.name as prison_name, count(*) as prisoner_count from incidents inner join prisons on incidents.prison_id = prisons.id where incidents.date_of_release is null group by prisons.name order by count(*) desc'

    limit.nil? ? find_by_sql(primary_sql) : find_by_sql(primary_sql + ' limit ' + limit.to_s)
  end
end
