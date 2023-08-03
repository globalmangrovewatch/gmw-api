FactoryBot.define do
  factory :ecoregion_report do
    sequence(:name) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    sequence(:url) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Internet.url
    end
  end
end
