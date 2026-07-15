# Automatically restart Puma workers when memory exceeds threshold
# This prevents R14 (Memory quota exceeded) errors on Heroku

if defined?(PumaWorkerKiller)
  PumaWorkerKiller.config do |config|
    # Restart worker when it exceeds this memory (in MB)
    # Heroku standard-1x has 512MB, so restart before hitting that
    config.ram = ENV.fetch("PUMA_WORKER_KILLER_RAM", 450).to_i

    # Check memory every N seconds
    config.frequency = 30

    # Percentage of memory to allow before killing (not used in single-process mode)
    config.percent_usage = 0.90

    # Rolling restart to avoid downtime (only applies with workers)
    config.rolling_restart_frequency = false

    # Log memory usage
    config.reaper_status_logs = true
  end

  PumaWorkerKiller.start
end
