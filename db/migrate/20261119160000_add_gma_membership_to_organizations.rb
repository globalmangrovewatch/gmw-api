class AddGmaMembershipToOrganizations < ActiveRecord::Migration[7.0]
  def change
    change_table :organizations, bulk: true do |t|
      t.string :gma_membership, null: false, default: "none"
      t.string :gma_status, null: false, default: "unverified"
      t.string :gma_chapter_name
    end

    add_check_constraint :organizations,
      "gma_membership IN ('none', 'member', 'national_chapter')",
      name: "organizations_gma_membership_check"
    add_check_constraint :organizations,
      "gma_status IN ('unverified', 'pending', 'verified', 'rejected')",
      name: "organizations_gma_status_check"
  end
end
