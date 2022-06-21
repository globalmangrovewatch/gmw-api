class Landscape < ApplicationRecord
    has_one :site
    has_and_belongs_to_many :organizations
end
