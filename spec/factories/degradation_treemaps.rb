FactoryBot.define do
  factory :degradation_treemap do
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:unit) do |n|
      ["ha", "%"].sample random: Random.new(n)
    end
    sequence(:year) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Date.between(from: "2014-01-01", to: "2022-01-01").year
    end
    sequence(:main_loss_driver) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.sentence
    end
    sequence(:indicator) do |n|
      DegradationTreemap.indicators.keys.sample random: Random.new(n)
    end
    location
  end
end