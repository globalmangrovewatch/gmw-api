require "rails_helper"

RSpec.describe LandscapeOrganizationInvitation, type: :model do
  describe "validations" do
    let(:landscape) { create(:landscape) }
    let(:inviting_organization) { create(:organization) }
    let(:invited_organization) { create(:organization) }
    let(:inviter) { create(:user) }

    def invitation_for(overrides = {})
      LandscapeOrganizationInvitation.new({
        landscape: landscape,
        inviting_organization: inviting_organization,
        invited_organization: invited_organization,
        invited_by: inviter,
        status: "pending"
      }.merge(overrides))
    end

    it "rejects an inviting organization that is not on the landscape" do
      invitation = invitation_for

      expect(invitation).not_to be_valid
      expect(invitation.errors[:inviting_organization]).to include("must already belong to this landscape")
    end

    it "rejects an invited organization that is already on the landscape" do
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting_organization)
      LandscapesOrganizations.create!(landscape: landscape, organization: invited_organization)
      invitation = invitation_for

      expect(invitation).not_to be_valid
      expect(invitation.errors[:invited_organization]).to include("is already part of this landscape")
    end

    it "rejects an invitation to an organization the inviter belongs to" do
      LandscapesOrganizations.create!(landscape: landscape, organization: inviting_organization)
      OrganizationsUsers.create!(organization: invited_organization, user: inviter, role: "org-user")
      invitation = invitation_for

      expect(invitation).not_to be_valid
      expect(invitation.errors[:invited_organization]).to include("can be linked directly")
    end

    it "rejects a second pending invitation and enforces that in the database" do
      invitation = create(:landscape_organization_invitation)
      duplicate = build(
        :landscape_organization_invitation,
        landscape: invitation.landscape,
        invited_organization: invitation.invited_organization
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:invited_organization]).to include("already has a pending invitation")
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows another invitation after the previous one was declined" do
      invitation = create(:landscape_organization_invitation, status: "declined")

      expect(build(
        :landscape_organization_invitation,
        landscape: invitation.landscape,
        invited_organization: invitation.invited_organization
      )).to be_valid
    end
  end

  describe "#inviter_name" do
    it "hides a name that contains an email address" do
      invitation = build(:landscape_organization_invitation, invited_by: build(:user, name: "ada.admin@wetlands.org"))

      expect(invitation.inviter_name).to be_nil
    end
  end

  describe "#respond" do
    let(:responder) { create(:user) }

    it "accepts the invitation, records the acknowledgement, and links the organization" do
      invitation = create(:landscape_organization_invitation)

      expect(invitation.respond("accepted", responder: responder, site_data_acknowledged: true)).to be(true)

      invitation.reload
      expect(invitation.status).to eq("accepted")
      expect(invitation.responded_by).to eq(responder)
      expect(invitation.responded_at).to be_present
      expect(invitation.site_data_acknowledged_at).to be_present
      expect(LandscapesOrganizations.exists?(
        landscape_id: invitation.landscape_id,
        organization_id: invitation.invited_organization_id
      )).to be(true)
    end

    it "does not accept without the site-data acknowledgement" do
      invitation = create(:landscape_organization_invitation)

      expect(invitation.respond("accepted", responder: responder, site_data_acknowledged: false)).to be(false)

      expect(invitation.reload.status).to eq("pending")
      expect(invitation.site_data_acknowledged_at).to be_nil
      expect(LandscapesOrganizations.exists?(
        landscape_id: invitation.landscape_id,
        organization_id: invitation.invited_organization_id
      )).to be(false)
    end

    it "declines without linking the organization or recording an acknowledgement" do
      invitation = create(:landscape_organization_invitation)

      expect(invitation.respond("declined", responder: responder, site_data_acknowledged: false)).to be(true)

      invitation.reload
      expect(invitation.status).to eq("declined")
      expect(invitation.responded_at).to be_present
      expect(invitation.site_data_acknowledged_at).to be_nil
      expect(LandscapesOrganizations.exists?(
        landscape_id: invitation.landscape_id,
        organization_id: invitation.invited_organization_id
      )).to be(false)
    end

    it "rolls back the decision when the organization link cannot be created" do
      invitation = create(:landscape_organization_invitation)
      allow(LandscapesOrganizations).to receive(:exists?).and_return(false)
      allow(LandscapesOrganizations).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique.new("duplicate"))

      expect {
        invitation.respond("accepted", responder: responder, site_data_acknowledged: true)
      }.to raise_error(ActiveRecord::RecordNotUnique)

      expect(invitation.reload.status).to eq("pending")
      expect(invitation.responded_at).to be_nil
      expect(invitation.site_data_acknowledged_at).to be_nil
    end

    it "leaves a decided invitation unchanged" do
      invitation = create(:landscape_organization_invitation, status: "declined", responded_at: Time.current)

      expect(invitation.respond("accepted", responder: responder, site_data_acknowledged: true)).to be(false)
      expect(invitation.reload.status).to eq("declined")
    end
  end
end
