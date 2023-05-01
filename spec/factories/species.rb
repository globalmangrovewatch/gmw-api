FactoryBot.define do
  factory :specie do
    sequence(:scientific_name) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    sequence(:common_name) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Lorem.word
    end
    sequence(:iucn_url) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Internet.url
    end
    sequence(:red_list_cat) do |n|
      ["ex", "ew", "re", "cr", "en", "vu", "lr", "nt", "lc", "dd"].sample random: Random.new(n)
    end
  end
end