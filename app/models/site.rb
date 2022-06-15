class Site < ApplicationRecord
    belongs_to :landscape
    has_many :registration_answers, dependent: :destroy
    validates :landscape, presence: true
end
