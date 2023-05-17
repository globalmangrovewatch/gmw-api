FactoryBot.define do
  factory :landscape do
    sequence(:landscape_name) { |n| "Landscape #{n}" }
  end
end
