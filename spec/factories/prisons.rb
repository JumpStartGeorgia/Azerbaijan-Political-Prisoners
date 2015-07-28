FactoryGirl.define do
  factory :prison do
    sequence(:name_en) { |n| "prison#{n}" }
  end
end
