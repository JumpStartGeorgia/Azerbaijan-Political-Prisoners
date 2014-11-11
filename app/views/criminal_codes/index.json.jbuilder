json.array!(@criminal_codes) do |criminal_code|
  json.extract! criminal_code, :id, :name
  json.url criminal_code_url(criminal_code, format: :json)
end
