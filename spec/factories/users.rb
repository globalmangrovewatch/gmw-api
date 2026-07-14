FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    name { Faker::Name.name }
    confirmed_at { Time.current }
    user_roles { [] }
  end
end
