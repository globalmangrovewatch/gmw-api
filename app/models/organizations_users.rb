class OrganizationsUsers < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  validates :user_id, uniqueness: { scope: :organization_id }
  validates :role, inclusion: { in: ["org-user", "org-admin", nil] }
end
