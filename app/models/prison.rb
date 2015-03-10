class Prison < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  def self.generate_prison_prisoner_count_chart_json
    File.open(Rails.public_path.join("chart_data/prison_prisoner_count_chart.json"), "w") do |f|
      f.write(prison_prisoner_count_chart.to_json)
    end
  end

  private

  def self.prison_prisoner_count_chart
    prison_names = []
    prisoner_counts = []

    prison_names_prisoner_counts.each do |prison_name_prisoner_count|
      prison_names.append(prison_name_prisoner_count[:prison_name])
      prisoner_counts.append(prison_name_prisoner_count[:prisoner_count])
    end

    return {prison_names: prison_names, series_data: prisoner_counts}
  end

  def self.prison_names_prisoner_counts
    return find_by_sql('select prisons.name as prison_name, count(*) as prisoner_count from incidents inner join prisons on incidents.prison_id = prisons.id group by prisons.name order by count(*) desc')
  end
end
