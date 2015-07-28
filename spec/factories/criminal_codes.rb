FactoryGirl.define do
  factory :criminal_code do
    sequence(:name_en) { |n| "name#{n}" }
  end
end
