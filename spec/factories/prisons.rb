FactoryGirl.define do
  factory :prison do
    sequence(:name) { |n| "prison#{n}" }
  end

end
