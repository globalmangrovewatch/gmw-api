class Specie < ApplicationRecord
  has_and_belongs_to_many :locations, join_table: 'locations_species'
  accepts_nested_attributes_for :locations
end
