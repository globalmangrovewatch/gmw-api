FactoryBot.define do
  factory :platform_notification do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    notification_type { "platform_update" }

    trait :newsletter do
      notification_type { "newsletter" }
    end

    trait :platform_update do
      notification_type { "platform_update" }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :scheduled do
      published_at { 1.week.from_now }
    end

    trait :draft do
      published_at { nil }
    end
  end
end
