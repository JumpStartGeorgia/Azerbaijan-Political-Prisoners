FactoryGirl.define do
  factory :page_section do
    name Faker::Company.bs
    label Faker::Company.bs
    content Faker::Lorem.paragraph
  end
end
