class Specie < ApplicationRecord
  # has_and_belongs_to_many :locations, join_table: 'species_locations'
  has_many :species_locations
  has_many :locations, through: :species_locations
  accepts_nested_attributes_for :locations
end
