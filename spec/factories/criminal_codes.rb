FactoryGirl.define do
  factory :criminal_code do
    sequence(:name) { |n| "name#{n}"}
  end

end
