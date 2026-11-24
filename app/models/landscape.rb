class Landscape < ApplicationRecord
  has_many :sites
  has_many :landscape_organization_invitations, dependent: :destroy
  has_and_belongs_to_many :organizations
end
