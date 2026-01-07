namespace :alerts do
  desc "Check for new location alert data and notify subscribed users"
  task check: :environment do
    puts "[#{Time.current}] Starting location alerts check..."
    CheckLocationAlertsJob.perform_now
    puts "[#{Time.current}] Location alerts check completed."
  end

  desc "Show alert check statistics"
  task stats: :environment do
    puts "Location Alert Statistics"
    puts "-" * 40

    snapshots = LocationAlertSnapshot.count
    latest_check = LocationAlertSnapshot.maximum(:last_checked_at)

    puts "Tracked locations:     #{snapshots}"
    puts "Last check:            #{latest_check || 'Never'}"
    puts ""

    subscribed_users = User.where(subscribed_to_location_alerts: true).count
    users_with_locations = User.joins(:user_locations)
                               .where(subscribed_to_location_alerts: true)
                               .where(user_locations: {alerts_enabled: true})
                               .distinct.count

    puts "User Statistics"
    puts "-" * 40
    puts "Subscribed to alerts:  #{subscribed_users}"
    puts "With enabled locations: #{users_with_locations}"
    puts ""

    puts "Recent Snapshots"
    puts "-" * 40
    LocationAlertSnapshot.order(last_checked_at: :desc).limit(10).each do |s|
      puts "  #{s.location_id}: #{s.date_count} dates, latest: #{s.latest_date}, checked: #{s.last_checked_at}"
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

  desc "Reset all snapshots (will trigger notifications on next check)"
  task reset: :environment do
    count = LocationAlertSnapshot.delete_all
    puts "Deleted #{count} snapshots."
  end
end

