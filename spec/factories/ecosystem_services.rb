FactoryBot.define do
  factory :ecosystem_service do
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:indicator) do |n|
      EcosystemService.indicators.keys.sample random: Random.new(n)
    end
    location
  end
end
