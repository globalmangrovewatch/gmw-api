FactoryBot.define do
  factory :flood_protection do
    location
    sequence(:indicator) do |n|
      FloodProtection.indicators.keys.sample random: Random.new(n)
    end
    sequence(:period) do |n|
      FloodProtection.periods.keys.sample random: Random.new(n)
    end
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:unit) do |n|
      FloodProtection.units.keys.sample random: Random.new(n)
    end
  end
end
