class Prison < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  def self.generate_prison_prisoner_count_chart_json
    File.open(Rails.public_path.join("chart_data/prison_prisoner_count_chart.json"), "w") do |f|
      f.write({prison_names: ["Prison !!!", "prison dsafljkdsaf"], series_data: [12, 23]}.to_json)
    end
  end
end
