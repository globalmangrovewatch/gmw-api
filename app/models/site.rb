class Site < ApplicationRecord
  belongs_to :landscape
  has_many :registration_intervention_answers, dependent: :destroy
  has_many :monitoring_answers, dependent: :destroy
  validates :landscape, presence: true

  scope :at_organizations, ->(names) do
    joins(landscape: :organizations).where(organizations: {organization_name: Array.wrap(names)})
  end
  scope :with_registration_intervention_answer, ->(question_id, selected_values) do
    where id: RegistrationInterventionAnswer.with_selected_values(question_id, selected_values).select(:site_id)
  end
end
