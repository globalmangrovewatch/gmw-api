FactoryBot.define do
  factory :landscape_organization_invitation do
    association :landscape
    association :inviting_organization, factory: :organization
    association :invited_organization, factory: :organization
    association :invited_by, factory: :user
    status { "pending" }

    after(:build) do |invitation|
      next if invitation.landscape_id.blank? || invitation.inviting_organization_id.blank?
      next if LandscapesOrganizations.exists?(
        landscape_id: invitation.landscape_id,
        organization_id: invitation.inviting_organization_id
      )

      LandscapesOrganizations.create!(
        landscape_id: invitation.landscape_id,
        organization_id: invitation.inviting_organization_id
      )
    end
  end
end
