class Specie < ApplicationRecord
  has_and_belongs_to_many :locations
end
