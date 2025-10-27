FactoryBot.define do
  factory :fishery_mitigation_potential do
    location
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:indicator_type) do |n|
      FisheryMitigationPotential.indicator_types.keys.sample random: Random.new(n)
    end
    sequence(:indicator) do |n|
      FisheryMitigationPotential.indicators.keys.sample random: Random.new(n)
    end
  end
end
