FactoryGirl.define do
  factory :prisoner do
    name 'MyName'

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
