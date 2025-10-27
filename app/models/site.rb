class Site < ApplicationRecord
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
end
