FactoryBot.define do
  factory :ecoregion do
    sequence(:indicator) do |n|
      Ecoregion.indicators.keys.sample random: Random.new(n)
    end
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:category) do |n|
      Ecoregion.categories.keys.sample random: Random.new(n)
    end
  end
end
