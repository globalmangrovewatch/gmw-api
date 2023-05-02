FactoryBot.define do
  factory :ecosystem_service do
    sequence(:value) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:indicator) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    location
  end
end
