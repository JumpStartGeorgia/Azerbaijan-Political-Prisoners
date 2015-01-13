FactoryGirl.define do
  factory :prisoner do
    name 'MyName'

    transient do
      incidents_count 1
    end

    after :build do |prisoner, evaluator|
      prisoner.incidents << FactoryGirl.build_list(:incident, evaluator.incidents_count, prisoner: prisoner)
    end
  end
end
