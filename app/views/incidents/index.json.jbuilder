json.array!(@incidents) do |incident|
  json.extract! incident, :id, :prisoner_id, :date_of_arrest, :description_of_arrest, :prison_id, :type_id, :subtype_id, :date_of_release, :description_of_release
  json.url incident_url(incident, format: :json)
end
