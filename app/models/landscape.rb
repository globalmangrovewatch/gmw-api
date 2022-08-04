class Landscape < ApplicationRecord
    has_many :sites
    has_and_belongs_to_many :organizations
end
