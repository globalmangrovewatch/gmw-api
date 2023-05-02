FactoryBot.define do
  factory :restoration_potential do
    sequence(:indicator) do |n|
      ["restorable_area", "mangrove_area", "restoration_potential_score"].sample random: Random.new(n)
    end
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal l_digits: 2
    end
    sequence(:unit) do |n|
      ["ha", "%"].sample random: Random.new(n)
    end
    sequence(:year) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Date.between(from: "2014-01-01", to: "2022-01-01").year
    end
    location
  end
end
