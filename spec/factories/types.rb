FactoryGirl.define do
  factory :type do
    sequence(:name) { |n| "type#{n}" }
  end
end
