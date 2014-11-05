json.array!(@prisoners) do |prisoner|
  json.extract! prisoner, :id, :name
  json.url prisoner_url(prisoner, format: :json)
end
