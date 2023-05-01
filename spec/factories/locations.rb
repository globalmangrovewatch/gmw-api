FactoryBot.define do
  factory :location do
    sequence(:name) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Nation.capital_city
    end
    sequence(:location_type) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    sequence(:iso) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    bounds { {} }
    geometry { {} }
    sequence(:area_m2) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:perimeter_m) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:coast_length_m) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal
    end
    sequence(:location_id) { |n| "Location-#{n}" }
  end

  trait :worldwide do
    location_type { "worldwide" }
  end
end
