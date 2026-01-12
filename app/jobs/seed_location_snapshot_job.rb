class SeedLocationSnapshotJob < ApplicationJob
  include AlertFetcher

  queue_as :default

  def perform(user_location_id)
    user_location = UserLocation.find_by(id: user_location_id)
    return unless user_location

    Rails.logger.info "[SeedLocationSnapshotJob] Seeding snapshot for user_location #{user_location_id}"

    if user_location.test_location?
      seed_test_location(user_location)
    elsif user_location.custom_location?
      seed_custom_location(user_location)
    else
      seed_system_location(user_location)
    end
  end

  private

  def seed_test_location(user_location)
    test_id = user_location.test_location_id
    response_data = fetch_alerts_by_id(test_id)
    return if response_data.blank?

    snapshot = LocationAlertSnapshot.find_or_initialize_for_custom(user_location)
    snapshot.update_from_response!(response_data)

    Rails.logger.info "[SeedLocationSnapshotJob] Created test snapshot for user_location #{user_location.id} (#{test_id})"
  end

  def seed_custom_location(user_location)
    response_data = fetch_alerts_with_geometry(user_location.geometry_feature_collection)
    return if response_data.blank?

    snapshot = LocationAlertSnapshot.find_or_initialize_for_custom(user_location)
    snapshot.update_from_response!(response_data)

    Rails.logger.info "[SeedLocationSnapshotJob] Created custom snapshot for user_location #{user_location.id}"
  end

  def seed_system_location(user_location)
    location_id = user_location.location_id
    existing = LocationAlertSnapshot.for_location(location_id)

    if existing.present?
      Rails.logger.info "[SeedLocationSnapshotJob] Snapshot for #{location_id} already exists, skipping"
      return
    end

    response_data = fetch_alerts_by_id(location_id)
    return if response_data.blank?

    snapshot = LocationAlertSnapshot.find_or_initialize_for_system(location_id)
    snapshot.update_from_response!(response_data)

    Rails.logger.info "[SeedLocationSnapshotJob] Created system snapshot for #{location_id}"
  end
end
