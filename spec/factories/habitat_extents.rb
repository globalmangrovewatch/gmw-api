FactoryBot.define do
  factory :habitat_extent do
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:indicator) do |n|
      ["habitat_extent_area", "linear_coverage"].sample random: Random.new(n)
    end
    sequence(:year) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Date.between(from: "2014-01-01", to: "2022-01-01").year
    end
    location
  end
end
