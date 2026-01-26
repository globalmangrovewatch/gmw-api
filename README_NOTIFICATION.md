# Email Notification System

Production-ready email notification system for sending emails to single or multiple recipients.

## Features

- Send to single or multiple recipients
- Plain text and HTML email support
- Custom email templates
- Bulk notifications
- Background/async processing with Sidekiq
- Email validation
- Automatic retry on failure

## Quick Start

### Simple Email

```ruby
NotificationService.send_notification(
  recipients: ["user@example.com"],
  subject: "Welcome",
  body: "Thank you for joining!"
)
```

### Multiple Recipients

```ruby
NotificationService.send_notification(
  recipients: ["user1@example.com", "user2@example.com", "user3@example.com"],
  subject: "System Announcement",
  body: "Important update for all users"
)
```

### Async Delivery (Recommended for Production)

```ruby
NotificationService.send_notification(
  recipients: ["user@example.com"],
  subject: "Welcome",
  body: "Thank you!",
  deliver_later: true
)
```

### HTML Email

```ruby
NotificationService.send_notification(
  recipients: ["user@example.com"],
  subject: "Welcome",
  body: "Plain text version",
  html_body: "<h1>Welcome!</h1><p>Thank you for joining!</p>"
)
```

### Custom Template

```ruby
NotificationService.send_custom_template(
  recipients: ["user@example.com"],
  subject: "Welcome!",
  template: "welcome_email",
  template_data: { 
    name: "John",
    activation_url: "https://example.com/activate"
  }
)
```

### Bulk Notifications

```ruby
notifications = [
  {
    recipients: ["user1@example.com"],
    subject: "Email 1",
    body: "Body 1"
  },
  {
    recipients: ["user2@example.com"],
    subject: "Email 2",
    body: "Body 2",
    html_body: "<p>HTML Body 2</p>"
  }
]

results = NotificationService.send_bulk_notifications(
  notifications: notifications,
  deliver_later: true
)
```

## Components

### NotificationMailer

Located at `app/mailers/notification_mailer.rb`

- `notification_email(recipients:, subject:, body:, html_body: nil)` - Send basic email
- `custom_template_email(recipients:, subject:, template:, template_data: {})` - Send with custom template

### NotificationService

Located at `app/services/notification_service.rb`

- `send_notification(...)` - Send single notification
- `send_custom_template(...)` - Send with custom template
- `send_bulk_notifications(...)` - Send multiple notifications

### NotificationJob

Located at `app/jobs/notification_job.rb`

Background job for async email delivery with automatic retry (3 attempts).

## Creating Custom Templates

1. Create HTML template: `app/views/notification_mailer/your_template.html.erb`
2. Create text template: `app/views/notification_mailer/your_template.text.erb`
3. Use `@template_data` variable to access your data

Example:
```erb
<h1>Hello, <%= @template_data[:name] %>!</h1>
<p>Your code: <%= @template_data[:code] %></p>
```

## Configuration

The system requires these environment variables:

```bash
SMTP_ADDRESS=your-smtp-server.com
SMTP_PORT=587
SMTP_USER_NAME=your-username
SMTP_PASSWORD=your-password
MAILER_DEFAULT_HOST=yourdomain.com
MAILER_FROM_ADDRESS=noreply@yourdomain.com
REDIS_URL=redis://your-redis:6379/0
```

## Validation

The service validates:
- Email format
- Non-empty recipients
- Non-blank subject and body

Invalid inputs raise `ArgumentError` with descriptive messages.

## Testing

Run the test script:

```bash
bundle exec rails runner test_notifications.rb
```

Or test manually in console:

```ruby
NotificationService.send_notification(
  recipients: ["your-email@example.com"],
  subject: "Test Email",
  body: "Testing the notification system"
)
```

## Error Handling

- `NotificationJob` automatically retries failed deliveries up to 3 times
- Bulk notifications continue processing even if individual emails fail
- Returns results for each notification including success/failure status

## Architecture

```
Application
    ↓
NotificationService (validation & logic)
    ↓
  ┌─┴─┐
sync async
  ↓   ↓
Mailer → Sidekiq → SMTP → Recipient
```

## License

See LICENSE file for details.
