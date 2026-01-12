namespace :alerts do
  desc "Trigger a full alert sync (same as admin panel button)"
  task sync: :environment do
    puts "[#{Time.current}] Starting location alerts sync..."

    sync_run = AlertSyncRun.create!(status: :pending)
    ProcessAlertSyncJob.perform_now(sync_run.id)

    sync_run.reload
    puts "[#{Time.current}] Sync completed."
    puts "  Status: #{sync_run.status}"
    puts "  System locations checked: #{sync_run.system_locations_checked}"
    puts "  Custom locations checked: #{sync_run.custom_locations_checked}"
    puts "  Notifications sent: #{sync_run.notifications_sent}"
    puts "  Errors: #{sync_run.errors_count}"
  end

  desc "Show alert statistics"
  task stats: :environment do
    puts "Location Alert Statistics"
    puts "-" * 40

    system_snapshots = LocationAlertSnapshot.for_system_locations.count
    custom_snapshots = LocationAlertSnapshot.for_custom_locations.count
    latest_check = LocationAlertSnapshot.maximum(:last_checked_at)

    puts "System location snapshots: #{system_snapshots}"
    puts "Custom location snapshots: #{custom_snapshots}"
    puts "Last check:                #{latest_check || 'Never'}"
    puts ""

    subscribed_users = User.where(subscribed_to_location_alerts: true).count
    users_with_locations = User.joins(:user_locations)
                               .where(subscribed_to_location_alerts: true)
                               .where(user_locations: {alerts_enabled: true})
                               .distinct.count

    puts "User Statistics"
    puts "-" * 40
    puts "Subscribed to alerts:   #{subscribed_users}"
    puts "With enabled locations: #{users_with_locations}"
    puts ""

    puts "Recent Sync Runs"
    puts "-" * 40
    AlertSyncRun.recent.limit(5).each do |run|
      puts "  #{run.id}: #{run.status} - #{run.created_at} (#{run.notifications_sent} sent, #{run.errors_count} errors)"
    end
    puts ""

    puts "Recent System Snapshots"
    puts "-" * 40
    LocationAlertSnapshot.for_system_locations.order(last_checked_at: :desc).limit(10).each do |s|
      puts "  #{s.location_id}: #{s.date_count} dates, latest: #{s.latest_date}"
    end
  end

  desc "Test fetch for a specific location (does not send notifications)"
  task :test, [:location_id] => :environment do |t, args|
    location_id = args[:location_id] || "worldwide"
    endpoint = ENV.fetch(
      "ALERTS_ENDPOINT_URL",
      "https://us-central1-mangrove-atlas-246414.cloudfunctions.net/fetch-alerts"
    )

    puts "Testing endpoint for location: #{location_id}"
    puts "-" * 50

    response = HTTParty.get(
      endpoint,
      query: {location_id: location_id},
      timeout: 30,
      headers: {"Accept" => "application/json"}
    )

    puts "Status: #{response.code}"

    if response.success?
      data = response.parsed_response
      if data.is_a?(Array)
        puts "Entries: #{data.count}"
        dates = data.map { |e| e.dig("date", "value") }.compact.sort
        puts "Date range: #{dates.first} to #{dates.last}"
        puts "Latest entry: #{data.find { |e| e.dig("date", "value") == dates.last }}"

        snapshot = LocationAlertSnapshot.find_by(location_id: location_id)
        if snapshot
          new_dates = snapshot.new_dates_in(data)
          puts "\nCompared to stored snapshot:"
          puts "  Stored dates: #{snapshot.date_count}"
          puts "  New dates: #{new_dates.any? ? new_dates.join(", ") : "None"}"
        else
          puts "\nNo existing snapshot for this location."
        end
      else
        puts "Unexpected response format: #{data.class}"
      end
    else
      puts "Error: #{response.body}"
    end
  rescue => e
    puts "Error: #{e.class} - #{e.message}"
  end

  desc "Reset all snapshots"
  task reset: :environment do
    count = LocationAlertSnapshot.delete_all
    puts "Deleted #{count} snapshots."
  end

  desc "Seed snapshots for all system locations (no notifications sent)"
  task seed: :environment do
    puts "[#{Time.current}] Seeding location alert snapshots for all system locations..."

    location_ids = Location.unscoped.pluck(:location_id).compact.uniq
    location_ids << "worldwide" unless location_ids.include?("worldwide")

    puts "Found #{location_ids.count} locations to seed"

    endpoint = ENV.fetch(
      "ALERTS_ENDPOINT_URL",
      "https://us-central1-mangrove-atlas-246414.cloudfunctions.net/fetch-alerts"
    )

    success_count = 0
    error_count = 0

    location_ids.each_with_index do |location_id, index|
      print "  [#{index + 1}/#{location_ids.count}] Seeding #{location_id}... "

      existing = LocationAlertSnapshot.find_by(location_id: location_id)
      if existing
        puts "already exists, skipping"
        next
      end

      response = HTTParty.get(
        endpoint,
        query: {location_id: location_id},
        timeout: 30,
        headers: {"Accept" => "application/json"}
      )

      if response.success? && response.parsed_response.is_a?(Array)
        data = response.parsed_response
        snapshot = LocationAlertSnapshot.create!(location_id: location_id)
        snapshot.update_from_response!(data)
        puts "✓ (#{data.count} dates, latest: #{snapshot.latest_date})"
        success_count += 1
      else
        puts "✗ (HTTP #{response.code})"
        error_count += 1
      end
    rescue => e
      puts "✗ (#{e.message})"
      error_count += 1
    end

    puts ""
    puts "[#{Time.current}] Seeding completed: #{success_count} success, #{error_count} errors"
  end

  namespace :test do
    desc "Setup a test location for a user"
    task :setup, [:email, :location_id] => :environment do |t, args|
      email = args[:email]
      location_id = args[:location_id] || "test_location"

      unless email
        puts "Usage: rake alerts:test:setup[user@example.com,test_location]"
        exit 1
      end

      unless location_id.start_with?("test_")
        puts "Error: Location ID must start with 'test_'"
        exit 1
      end

      user = User.find_by(email: email)
      unless user
        puts "Error: User not found: #{email}"
        exit 1
      end

      unless user.subscribed_to_location_alerts?
        user.update!(subscribed_to_location_alerts: true)
        puts "Enabled location alerts for #{email}"
      end

      TestAlertData.for_location(location_id)

      user_location = user.user_locations.find_by("bounds->>'test_location_id' = ?", location_id)
      unless user_location
        dummy_geometry = {
          "type" => "Point",
          "coordinates" => [0, 0]
        }
        user_location = user.user_locations.create!(
          name: "Test Location (#{location_id})",
          alerts_enabled: true,
          custom_geometry: dummy_geometry,
          bounds: {test_location_id: location_id}
        )
      end

      puts "Created test location '#{location_id}' for #{email}"
      puts "User location ID: #{user_location.id}"
      puts ""
      puts "Next steps:"
      puts "  1. Run: rake alerts:sync         # Seeds initial snapshot"
      puts "  2. Run: rake alerts:test:add_date[#{location_id}]  # Add a new date"
      puts "  3. Run: rake alerts:sync         # Triggers notification"
    end

    desc "Add a date to test data (triggers alert on next sync)"
    task :add_date, [:location_id, :date] => :environment do |t, args|
      location_id = args[:location_id] || "test_location"
      date = args[:date] || Date.current.to_s

      unless location_id.start_with?("test_")
        puts "Error: Location ID must start with 'test_'"
        exit 1
      end

      test_data = TestAlertData.for_location(location_id)
      test_data.add_date!(date)

      puts "Added date #{date} to #{location_id}"
      puts "Current dates: #{test_data.dates.count}"
      puts ""
      puts "Run 'rake alerts:sync' to trigger notification"
    end

    desc "Reset test data to defaults"
    task :reset, [:location_id] => :environment do |t, args|
      location_id = args[:location_id] || "test_location"

      test_data = TestAlertData.find_by(location_id: location_id)
      if test_data
        test_data.reset!
        puts "Reset #{location_id} to default dates"
      else
        puts "No test data found for #{location_id}"
      end
    end

    desc "Show test data status"
    task :status, [:location_id] => :environment do |t, args|
      location_id = args[:location_id] || "test_location"

      test_data = TestAlertData.find_by(location_id: location_id)
      unless test_data
        puts "No test data found for #{location_id}"
        puts "Run: rake alerts:test:setup[user@example.com,#{location_id}]"
        exit 0
      end

      puts "Test Data: #{location_id}"
      puts "-" * 40
      puts "Dates:"
      test_data.dates.sort_by { |d| d.dig("date", "value") || "" }.reverse.each do |d|
        puts "  #{d.dig("date", "value")}: count=#{d["count"]}"
      end
      puts ""

      user_locations = UserLocation.where("bounds->>'test_location_id' = ?", location_id).includes(:user)
      first_ul = user_locations.first
      if first_ul
        snapshot = LocationAlertSnapshot.find_by(user_location_id: first_ul.id)
        if snapshot
          puts "Snapshot:"
          puts "  Last checked: #{snapshot.last_checked_at}"
          puts "  Date count: #{snapshot.date_count}"
          puts "  Latest date: #{snapshot.latest_date}"
        else
          puts "Snapshot: Not yet created (run 'rake alerts:sync' first)"
        end
      else
        puts "Snapshot: No user locations found for this test location"
      end
      puts ""

      puts "Users with this location:"
      user_locations.each do |ul|
        status = ul.alerts_enabled && ul.user.subscribed_to_location_alerts? ? "✓" : "✗"
        puts "  #{status} #{ul.user.email} (alerts_enabled: #{ul.alerts_enabled})"
      end
    end

    desc "Full test cycle: setup, sync, add date, sync again"
    task :full_cycle, [:email, :location_id] => :environment do |t, args|
      email = args[:email]
      location_id = args[:location_id] || "test_location"

      unless email
        puts "Usage: rake alerts:test:full_cycle[user@example.com,test_location]"
        exit 1
      end

      puts "=" * 50
      puts "STEP 1: Setup test location"
      puts "=" * 50
      Rake::Task["alerts:test:setup"].invoke(email, location_id)
      Rake::Task["alerts:test:setup"].reenable
      puts ""

      puts "=" * 50
      puts "STEP 2: Initial sync (seeds snapshot, no notification)"
      puts "=" * 50
      Rake::Task["alerts:sync"].invoke
      Rake::Task["alerts:sync"].reenable
      puts ""

      puts "=" * 50
      puts "STEP 3: Add new date to test data"
      puts "=" * 50
      Rake::Task["alerts:test:add_date"].invoke(location_id)
      Rake::Task["alerts:test:add_date"].reenable
      puts ""

      puts "=" * 50
      puts "STEP 4: Sync again (should trigger notification)"
      puts "=" * 50
      Rake::Task["alerts:sync"].invoke
      Rake::Task["alerts:sync"].reenable
      puts ""

      puts "=" * 50
      puts "DONE! Check your email for the alert notification."
      puts "=" * 50
    end
  end
end

