FactoryGirl.define do
  factory :article do
    criminal_code
    sequence(:number) { |n| "101.#{n}" }
  end
end
