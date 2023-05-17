FactoryBot.define do
  factory :organization do
    sequence(:organization_name) { |n| "Organization #{n}" }
  end
end
