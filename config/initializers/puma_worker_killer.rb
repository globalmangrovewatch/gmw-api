# Automatically restart Puma when memory exceeds threshold
# This helps prevent R14 (Memory quota exceeded) errors on Heroku

if defined?(PumaWorkerKiller) && ENV["RAILS_ENV"] == "production"
  PumaWorkerKiller.config do |config|
    # Heroku standard-1x has 512MB, restart at 480MB
    config.ram = ENV.fetch("PUMA_WORKER_KILLER_RAM", 480).to_i
    config.frequency = 15
    config.percent_usage = 0.90
    config.rolling_restart_frequency = false
    config.reaper_status_logs = true
  end

  PumaWorkerKiller.start
end
