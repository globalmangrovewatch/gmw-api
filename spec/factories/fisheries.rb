FactoryBot.define do
  factory :fishery do
    location
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:category) do |n|
      Fishery.categories.keys.sample random: Random.new(n)
    end
    sequence(:indicator) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    sequence(:year) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Date.between(from: "2014-01-01", to: "2022-01-01").year
    end
  end
end
