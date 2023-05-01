FactoryBot.define do
  factory :international_status do
    sequence(:indicator) do |n|
      InternationalStatus.indicators.keys.sample random: Random.new(n)
    end
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    location
  end
end