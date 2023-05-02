FactoryBot.define do
  factory :blue_carbon_investment do
    sequence(:category) do |n|
      ["carbon_5", "carbon_10", "protected", "remaining"].sample random: Random.new(n)
    end
    sequence(:area) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:description) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.paragraph
    end
    location
  end
end
