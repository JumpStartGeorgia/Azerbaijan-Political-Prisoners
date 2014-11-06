json.array!(@prisons) do |prison|
  json.extract! prison, :id, :name
  json.url prison_url(prison, format: :json)
end
