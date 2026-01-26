FactoryBot.define do
  factory :location_alert_snapshot do
    location_id { "MyString" }
    latest_date { "2026-01-07" }
    date_count { 1 }
    last_response { "" }
    last_checked_at { "2026-01-07 09:54:59" }
  end
end
