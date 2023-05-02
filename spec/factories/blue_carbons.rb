FactoryBot.define do
  factory :blue_carbon do
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:indicator) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    sequence(:year) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Date.between(from: "2014-01-01", to: "2022-01-01").year
    end
    location
  end
end
