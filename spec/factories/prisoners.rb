FactoryGirl.define do
  factory :prisoner do
    name 'MyName'

    factory :prisoner_with_incidents do
      transient do
        incidents_count 1
      end

      after(:build) do |prisoner, evaluator|
        prisoner.incidents << FactoryGirl.build_list(:incident, evaluator.incidents_count, prisoner: nil)
      end
    end

    #factory :prisoner_with_incident do
    #  incident
    #end
  end
end
