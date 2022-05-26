class Site < ApplicationRecord
    has_many :registration_answers, dependent: :destroy
end
