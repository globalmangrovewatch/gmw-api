FactoryBot.define do
  factory :location_resource do
    location
    sequence(:name) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    sequence(:description) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.paragraph
    end
    sequence(:link) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Internet.url
    end
  end
end
