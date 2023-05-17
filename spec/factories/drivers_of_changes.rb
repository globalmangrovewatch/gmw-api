FactoryBot.define do
  factory :drivers_of_change do
    location
    sequence(:variable) do |n|
      DriversOfChange.variables.keys.sample random: Random.new(n)
    end
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:primary_driver) do |n|
      DriversOfChange.primary_drivers.keys.sample random: Random.new(n)
    end
  end
end
