FactoryGirl.define do
  factory :incident do
    date_of_arrest Date.new(2012, 12, 3)
    prison
    type
    association :prisoner, factory: :prisoner_with_incidents
  end

end
