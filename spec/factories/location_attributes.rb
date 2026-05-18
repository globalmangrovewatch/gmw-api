FactoryBot.define do
  factory :location_attribute do
    location
    sequence(:legal_status) do |n|
      LocationAttribute.legal_statuses.keys.sample random: Random.new(n)
    end
    sequence(:mangrove_breakthrough_committed) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Boolean.boolean
    end
  end
end
