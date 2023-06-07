FactoryBot.define do
  factory :national_dashboard do
    location
    sequence(:source) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    sequence(:indicator) do |n|
      NationalDashboard.indicators.keys.sample random: Random.new(n)
    end
    sequence(:year) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Date.between(from: "2014-01-01", to: "2022-01-01").year
    end
    sequence(:layer_link) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Internet.url
    end
    sequence(:download_link) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Internet.url
    end
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:unit) do |n|
      NationalDashboard.units.keys.sample random: Random.new(n)
    end
  end
end
