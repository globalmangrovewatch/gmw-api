class TestAlertData < ApplicationRecord
  validates :location_id, presence: true, uniqueness: true

  serialize :dates, coder: JSON

  def self.for_location(location_id)
    find_or_create_by(location_id: location_id) do |record|
      record.dates = default_dates
    end
  end

  def self.default_dates
    [
      {"date" => {"value" => 1.year.ago.to_date.to_s}, "count" => 100},
      {"date" => {"value" => 6.months.ago.to_date.to_s}, "count" => 150},
      {"date" => {"value" => 3.months.ago.to_date.to_s}, "count" => 200}
    ]
  end

  def add_date!(date_str = nil, count = nil)
    date_str ||= Date.current.to_s
    count ||= rand(100..500)

    self.dates ||= []
    self.dates << {"date" => {"value" => date_str}, "count" => count}
    save!

    date_str
  end

  def remove_date!(date_str)
    self.dates ||= []
    self.dates.reject! { |d| d.dig("date", "value") == date_str }
    save!
  end

  def reset!
    update!(dates: self.class.default_dates)
  end

  def as_response
    dates || []
  end

  def self.test_location?(location_id)
    location_id.to_s.start_with?("test_")
  end
end
