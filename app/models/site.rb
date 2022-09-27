class Site < ApplicationRecord
    belongs_to :landscape
    has_many :registration_intervention_answers, dependent: :destroy
    has_many :registration_answers, dependent: :destroy
    has_many :intervention_answers, dependent: :destroy
    has_many :monitoring_answers, dependent: :destroy
    validates :landscape, presence: true
end
