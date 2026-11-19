class AddGmaMembershipReview < ActiveRecord::Migration[7.0]
  def change
    add_reference :organizations, :gma_reviewed_by, foreign_key: {to_table: :users, on_delete: :nullify}
    add_column :organizations, :gma_reviewed_at, :datetime
    add_column :organizations, :gma_review_reason, :text
    add_index :organizations, [:gma_status, :gma_membership], name: "index_organizations_on_gma_status_and_membership"
    add_column :users, :gma_validator, :boolean, null: false, default: false
  end
end
