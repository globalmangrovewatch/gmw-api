class Site < ApplicationRecord
  SITE_AREA_QUESTION_ID = "1.3"

  belongs_to :landscape
  has_many :registration_intervention_answers, dependent: :destroy
  has_many :monitoring_answers, dependent: :destroy
  validates :landscape, presence: true

  scope :at_organizations, ->(names) do
    joins(landscape: :organizations).where(organizations: {organization_name: Array.wrap(names)})
  end
  scope :for_location, ->(location_id) do
    where("ST_Intersects(ST_SetSRID(sites.area, 4326), (SELECT ST_GeomFromGeoJSON(geometry) FROM locations WHERE id = ?))", location_id)
  end
  scope :with_registration_intervention_answer, ->(question_id, selected_values) do
    where id: RegistrationInterventionAnswer.with_selected_values(question_id, selected_values).select(:site_id)
  end

  # TODO if this is too much of a performance penalty, we can try to retrieve this in a single query (avoid N+1)
  def causes_of_decline
    RegistrationInterventionAnswer.category_for_site("4.2", id)
  end

  def ecological_aims
    RegistrationInterventionAnswer.answer_for_site("3.1", id)
  end

  def socioeconomic_aims
    RegistrationInterventionAnswer.answer_for_site("3.2", id)
  end

  def community_activities
    RegistrationInterventionAnswer.answer_for_site("6.4", id)
  end

  def intervention_types
    RegistrationInterventionAnswer.answer_for_site("6.2", id)
  end

  def organization_names
    landscape.organizations.pluck(:organization_name)
  end

  def self.area_geometry_from_geojson_answer(answer_value)
    payload = normalize_geojson_answer(answer_value)
    return nil if payload.blank?

    features_json = payload["features"].to_json
    wkt = connection.select_value(<<~SQL.squish)
      SELECT ST_AsText(
        ST_Union(
          ST_SetSRID(
            ST_MakeValid(ST_GeomFromGeoJSON(feat->'geometry')),
            4326
          )
        )
      )
      FROM jsonb_array_elements(#{connection.quote(features_json)}::jsonb) AS feat
    SQL
    return nil if wkt.blank?

    rgeo_factory.parse_wkt(wkt)
  rescue StandardError => e
    Rails.logger.error("Failed to derive site area geometry: #{e.class} - #{e.message}")
    nil
  end

  def self.normalize_geojson_answer(answer_value)
    payload = parse_geojson_answer(answer_value)
    return nil unless payload.is_a?(Hash)
    return nil unless payload["features"].is_a?(Array)
    return nil if payload["features"].empty?

    payload
  end

  def self.parse_geojson_answer(answer_value)
    return nil if answer_value.blank?

    payload = answer_value.is_a?(String) ? JSON.parse(answer_value) : answer_value
    payload = payload.to_unsafe_h if payload.respond_to?(:to_unsafe_h)
    payload.deep_stringify_keys
  rescue StandardError
    nil
  end

  def self.explicit_empty_geometry?(answer_value)
    payload = parse_geojson_answer(answer_value)
    return true unless payload.is_a?(Hash)
    return true unless payload.key?("features")

    payload["features"].is_a?(Array) && payload["features"].empty?
  end

  def self.rgeo_factory
    @rgeo_factory ||= RGeo::Cartesian.factory(srid: 4326)
  end

  def sync_area_from_geojson_answer!(answer_value)
    geometry = self.class.area_geometry_from_geojson_answer(answer_value)

    if geometry.nil?
      update(area: nil) if self.class.explicit_empty_geometry?(answer_value)
      return
    end

    update(area: geometry)
  rescue StandardError => e
    Rails.logger.error("Failed to sync site #{id} area: #{e.class} - #{e.message}")
  end
end
