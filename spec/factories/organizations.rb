FactoryBot.define do
  factory :organization do
    sequence(:organization_name) { |n| "Organization #{n}" }

    transient do
      country_location_ids { nil }
    end

    after(:build) do |organization, evaluator|
      if !evaluator.country_location_ids.nil?
        organization.country_location_ids = evaluator.country_location_ids
      elsif organization.organizations_countries.empty?
        location = Location.create!(
          name: "Factory Country #{organization.organization_name}",
          location_type: "country",
          iso: "ZZZ",
          location_id: "factory-country-#{SecureRandom.hex(8)}"
        )
        organization.country_location_ids = [location.location_id]
      end
    end
  end
end
