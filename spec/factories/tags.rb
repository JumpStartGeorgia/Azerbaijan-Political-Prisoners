FactoryGirl.define do
  factory :tag do
    sequence(:name_en) { |n| "tag#{n}" }

    factory :tag_with_description do
      description Faker::Lorem.paragraph
    end

    factory :tag_with_incidents do
      transient do
        incidents_count 2
      end

      after :create do |_tag, evaluator|
        create_list(:incident, evaluator.incidents_count)
      end
    end
  end
end
