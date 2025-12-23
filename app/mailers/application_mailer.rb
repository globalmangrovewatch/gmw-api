class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@gmw-api.com")
  layout "mailer"
end
