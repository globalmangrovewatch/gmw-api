puts "=" * 60
puts "Testing Email Notification System"
puts "=" * 60

def test_with_rescue(test_name)
  print "\n#{test_name}... "
  yield
  puts "✓ SUCCESS"
  true
rescue => e
  puts "✗ FAILED"
  puts "  Error: #{e.message}"
  false
end

results = []

results << test_with_rescue("1. Simple text email") do
  NotificationService.send_notification(
    recipients: ["test@example.com"],
    subject: "Test Email - Simple Text",
    body: "This is a simple test notification sent from the GMW API notification system."
  )
end

results << test_with_rescue("2. HTML email") do
  NotificationService.send_notification(
    recipients: ["test@example.com"],
    subject: "Test Email - HTML Version",
    body: "This is the plain text version",
    html_body: "<h1>HTML Test</h1><p>This is the <strong>HTML version</strong> with formatting!</p>"
  )
end

results << test_with_rescue("3. Multiple recipients") do
  NotificationService.send_notification(
    recipients: ["user1@example.com", "user2@example.com", "user3@example.com"],
    subject: "Test Email - Multiple Recipients",
    body: "This email is being sent to multiple recipients at once."
  )
end

results << test_with_rescue("4. Welcome email template") do
  NotificationService.send_custom_template(
    recipients: ["newuser@example.com"],
    subject: "Welcome to GMW API!",
    template: "welcome_email",
    template_data: {
      name: "Test User",
      activation_url: "https://example.com/activate/test-token-123"
    }
  )
end

results << test_with_rescue("5. Bulk notifications") do
  notifications = [
    {
      recipients: ["bulk1@example.com"],
      subject: "Bulk Email 1",
      body: "First bulk notification"
    },
    {
      recipients: ["bulk2@example.com"],
      subject: "Bulk Email 2",
      body: "Second bulk notification",
      html_body: "<p>Second bulk notification with <strong>HTML</strong></p>"
    },
    {
      recipients: ["bulk3@example.com"],
      subject: "Bulk Email 3",
      body: "Third bulk notification"
    }
  ]

  bulk_results = NotificationService.send_bulk_notifications(
    notifications: notifications,
    deliver_later: false
  )

  failed = bulk_results.select { |r| !r[:success] }
  raise "#{failed.count} bulk emails failed" if failed.any?
end

results << test_with_rescue("6. Validation - Invalid email") do
  begin
    NotificationService.send_notification(
      recipients: ["not-an-email"],
      subject: "Test",
      body: "Test"
    )
    raise "Should have raised ArgumentError"
  rescue ArgumentError => e
    raise unless e.message.include?("Invalid email format")
  end
end

results << test_with_rescue("7. Validation - Empty recipients") do
  begin
    NotificationService.send_notification(
      recipients: [],
      subject: "Test",
      body: "Test"
    )
    raise "Should have raised ArgumentError"
  rescue ArgumentError => e
    raise unless e.message.include?("Recipients cannot be empty")
  end
end

results << test_with_rescue("8. Validation - Blank subject") do
  begin
    NotificationService.send_notification(
      recipients: ["test@example.com"],
      subject: "",
      body: "Test"
    )
    raise "Should have raised ArgumentError"
  rescue ArgumentError => e
    raise unless e.message.include?("Subject cannot be blank")
  end
end

puts "\n" + "=" * 60
puts "Test Summary"
puts "=" * 60
passed = results.count(true)
failed = results.count(false)
total = results.count

puts "Passed: #{passed}/#{total}"
puts "Failed: #{failed}/#{total}"

if failed.zero?
  puts "\n✅ All tests passed!"
  puts "\n📧 Check your emails at: http://localhost:1080"
  puts "\nTotal emails sent: #{ActionMailer::Base.deliveries.count}"
else
  puts "\n❌ Some tests failed. Check the errors above."
end

puts "=" * 60

