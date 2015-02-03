FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| "tag#{n}" }

    factory :tag_with_incidents do
      transient do
        incidents_count 2
      end

      after :create do |tag, evaluator|
        create_list(:incident, evaluator.incidents_count)
      end
    end
  end

end
