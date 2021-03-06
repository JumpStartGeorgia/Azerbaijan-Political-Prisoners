FactoryGirl.define do
  factory :prisoner do
    sequence(:name_en) { |n| "prisoner##{n}" }
    gender_id 1

    factory :prisoner_with_incidents do
      transient do
        incidents_count 1
      end

      after :create do |prisoner, evaluator|
        create_list(:incident, evaluator.incidents_count, prisoner: prisoner)
      end
    end
  end
end
