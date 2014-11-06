json.array!(@charges) do |charge|
  json.extract! charge, :id, :number, :criminal_code, :description
  json.url charge_url(charge, format: :json)
end
