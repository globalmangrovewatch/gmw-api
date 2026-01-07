if defined?(Sidekiq)
  Sidekiq.configure_server do |config|
    config.redis = {url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")}

    config.on(:startup) do
      schedule_file = Rails.root.join("config", "sidekiq.yml")
      if File.exist?(schedule_file) && defined?(Sidekiq::Scheduler)
        schedule = YAML.load_file(schedule_file)[:scheduler][:schedule]
        Sidekiq::Scheduler.enabled = ENV.fetch("SIDEKIQ_SCHEDULER_ENABLED", "true") == "true"
        Sidekiq.schedule = schedule if schedule
      end
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")}
  end
end

