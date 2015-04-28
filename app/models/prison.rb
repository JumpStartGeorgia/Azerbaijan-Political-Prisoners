class Prison < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  def as_csv(options={})
    attributes.slice('name', 'description')
  end

  def self.generate_prison_prisoner_count_chart_json
    dir_path = Rails.public_path.join("data")
    json_path = dir_path.join("prison_prisoner_count_chart.json")
    # if folder path not exist, create it
    FileUtils.mkpath(dir_path) if !File.exists?(dir_path)
    File.open(json_path, "w") do |f|
      f.write(prison_prisoner_count_chart.to_json)
    end
  end

  private

  def self.prison_prisoner_count_chart
    prison_names_links_counts = []

    prison_names_prisoner_counts.each do |prison_name_prisoner_count|
      prison_names_links_counts.append({
          y: prison_name_prisoner_count[:prisoner_count],
          name: prison_name_prisoner_count[:prison_name],
          link: Rails.application.routes.url_helpers.prison_path(prison_name_prisoner_count[:prison_id])
                                       })
    end

    return prison_names_links_counts

    #
    #prison_names_and_links = []
    #prisoner_counts = []
    #
    #prison_names_prisoner_counts.each do |prison_name_prisoner_count|
    #  prison_name = prison_name_prisoner_count[:prison_name]
    #  prison_names_and_links.append({name: prison_name, link: Rails.application.routes.url_helpers.prison_path(prison_name_prisoner_count[:prison_id])})
    #  prisoner_counts.append(prison_name_prisoner_count[:prisoner_count])
    #end
    #
    #return {
    #    prison_names_and_links: prison_names_and_links,
    #    prisoner_counts: prisoner_counts
    #}
  end

  def self.prison_names_prisoner_counts
    return find_by_sql('select prisons.id as prison_id, prisons.name as prison_name, count(*) as prisoner_count from incidents inner join prisons on incidents.prison_id = prisons.id group by prisons.name order by count(*) desc')
  end
end
