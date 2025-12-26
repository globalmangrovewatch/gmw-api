FactoryBot.define do
  factory :user_location do
    user
    name { Faker::Address.city }
    position { 0 }

    trait :with_system_location do
      location
    end

    trait :with_custom_geometry do
      custom_geometry do
        {
          type: "Polygon",
          coordinates: [
            [
              [-122.4, 37.8],
              [-122.4, 37.7],
              [-122.3, 37.7],
              [-122.3, 37.8],
              [-122.4, 37.8]
            ]
          ]
        }
      end
      bounds do
        {
          north: 37.8,
          south: 37.7,
          east: -122.3,
          west: -122.4
        }
      end
    end
  end
end

