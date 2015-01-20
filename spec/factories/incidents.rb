FactoryGirl.define do
  factory :incident do
    date_of_arrest Date.new(2012, 12, 3)
    type
    prisoner
  end
end
