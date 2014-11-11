json.array!(@articles) do |article|
  json.extract! article, :id, :number, :criminal_code_id, :description
  json.url article_url(article, format: :json)
end
