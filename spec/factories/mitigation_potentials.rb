FactoryBot.define do
  factory :mitigation_potential, class: MitigationPotentials do
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:indicator) do |n|
      MitigationPotentials.indicators.keys.sample random: Random.new(n)
    end
    sequence(:category) do |n|
      MitigationPotentials.categories.keys.sample random: Random.new(n)
    end
    sequence(:year) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Date.between(from: "2014-01-01", to: "2022-01-01").year
    end
    location
  end
end
