FactoryBot.define do
  factory :organization_join_request do
    association :organization
    association :user
    status { "pending" }
    message { "I would like to join" }
  end
end
