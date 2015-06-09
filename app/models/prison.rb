class Prison < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << %w(Name Description)
      all.each do |prison|
        csv << [prison.name, prison.description]
      end
    end
  end

  def self.generate_prison_prisoner_count_chart_json
    dir_path = Rails.public_path.join('system', 'json')
    json_path = dir_path.join('prison_prisoner_count_chart.json')
    # if folder path not exist, create it
    FileUtils.mkpath(dir_path) unless File.exist?(dir_path)
    File.open(json_path, 'w') do |f|
      f.write(prison_prisoner_count_chart.to_json)
    end
  end

  private

  def self.prison_prisoner_count_chart
    prisons = []

    prison_names_prisoner_counts(10).each do |prison_name_prisoner_count|
      prisons.append(y: prison_name_prisoner_count[:prisoner_count],
                     name: prison_name_prisoner_count[:prison_name],
                     link: "/#{I18n.locale}/prisons/#{prison_name_prisoner_count[:prison_id]}")
    end

    prisons
  end

  def self.prison_names_prisoner_counts(limit=nil)
    primary_sql = 'select prisons.id as prison_id, prisons.name as prison_name, count(*) as prisoner_count from incidents inner join prisons on incidents.prison_id = prisons.id group by prisons.name order by count(*) desc'

    limit.nil? ? find_by_sql(primary_sql) : find_by_sql(primary_sql + ' limit ' + limit.to_s)
  end
end
