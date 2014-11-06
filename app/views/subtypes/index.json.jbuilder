json.array!(@subtypes) do |subtype|
  json.extract! subtype, :id, :name, :type_id, :description
  json.url subtype_url(subtype, format: :json)
end
