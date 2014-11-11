json.array!(@charges) do |charge|
  json.extract! charge, :id, :incident_id, :article_id
  json.url charge_url(charge, format: :json)
end
