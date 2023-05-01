FactoryBot.define do
  factory :widget_protected_area, class: WidgetProtectedAreas do
    sequence(:year) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Date.between(from: "2014-01-01", to: "2022-01-01").year
    end
    sequence(:total_area) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:protected_area) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    location
  end
end