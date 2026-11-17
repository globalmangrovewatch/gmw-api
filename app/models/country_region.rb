require "csv"

class CountryRegion < ApplicationRecord
  REGIONS = %w[Africa Americas Asia Europe Oceania].freeze

  validates :iso3, presence: true, uniqueness: true
  validates :region, presence: true, inclusion: {in: REGIONS}

  def self.import_reference_data!
    rows = reference_rows.map { |iso3, region| {iso3: iso3, region: region} }
    return if rows.empty?

    upsert_all(rows, unique_by: :iso3, update_only: [:region])
  end

  def self.reference_rows
    rows = {}
    [m49_path, manual_path].each do |path|
      CSV.foreach(path, headers: true) do |row|
        iso3 = row["iso3"].to_s.strip.upcase
        region = row["region"].to_s.strip
        next if iso3.empty? || !REGIONS.include?(region)

        rows[iso3] = region
      end
    end
    rows
  end

  def self.m49_path
    Rails.root.join("db/data/un_m49_country_regions.csv")
  end

  def self.manual_path
    Rails.root.join("db/data/country_region_manual.csv")
  end
end
