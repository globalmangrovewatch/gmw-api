require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "GMA membership claim" do
    it "stores a new claim as pending and clears a chapter name that does not apply" do
      organization = create(:organization, gma_membership: "member", gma_chapter_name: "Kenya Chapter")

      expect(organization.gma_membership).to eq("member")
      expect(organization.gma_status).to eq("pending")
      expect(organization.gma_chapter_name).to be_nil
    end

    it "stores a national chapter name without surrounding spaces" do
      organization = create(
        :organization,
        gma_membership: "national_chapter",
        gma_chapter_name: "  Kenya Chapter  "
      )

      expect(organization.gma_status).to eq("pending")
      expect(organization.gma_chapter_name).to eq("Kenya Chapter")
    end

    it "leaves an unchanged claim's status alone, including verified and rejected" do
      verified = create(:organization, gma_membership: "member")
      verified.update_columns(gma_status: "verified")
      rejected = create(:organization, gma_membership: "national_chapter", gma_chapter_name: "Kenya Chapter")
      rejected.update_columns(gma_status: "rejected")

      verified.update!(organization_name: "Renamed Coast", gma_membership: "member")
      rejected.update!(gma_chapter_name: "Kenya Chapter")

      expect(verified.reload.gma_status).to eq("verified")
      expect(rejected.reload.gma_status).to eq("rejected")
    end

    it "resets the status to pending when the claim changes" do
      organization = create(:organization, gma_membership: "member")
      organization.update_columns(gma_status: "verified")

      organization.update!(gma_membership: "national_chapter", gma_chapter_name: "Kenya Chapter")

      expect(organization.gma_status).to eq("pending")
      expect(organization.gma_chapter_name).to eq("Kenya Chapter")

      organization.update_columns(gma_status: "verified")
      organization.update!(gma_chapter_name: "Tanzania Chapter")

      expect(organization.gma_status).to eq("pending")
    end

    it "clears the status and chapter name when the claim is set back to none" do
      organization = create(:organization, gma_membership: "national_chapter", gma_chapter_name: "Kenya Chapter")
      organization.update_columns(gma_status: "verified")

      organization.update!(gma_membership: "none", gma_chapter_name: "Kenya Chapter")

      expect(organization.gma_membership).to eq("none")
      expect(organization.gma_status).to eq("unverified")
      expect(organization.gma_chapter_name).to be_nil
    end

    it "rejects a membership value outside the allowed list" do
      organization = create(:organization)

      expect(organization.update(gma_membership: "yes")).to be(false)
      expect(organization.errors[:gma_membership]).to include("is not included in the list")
      expect(organization.reload.gma_membership).to eq("none")
    end
  end

  describe "#gma_representation_for" do
    let(:member) { create(:user) }
    let(:outsider) { create(:user) }
    let(:organization) do
      create(:organization, gma_membership: "national_chapter", gma_chapter_name: "Kenya Chapter")
    end

    before do
      OrganizationsUsers.create!(organization: organization, user: member, role: "org-user")
    end

    it "shows the claim and status to members and hides an unverified claim from everyone else" do
      expect(organization.gma_representation_for(member)).to eq(
        gma_membership: "national_chapter",
        gma_status: "pending",
        gma_chapter_name: "Kenya Chapter"
      )
      expect(organization.gma_representation_for(outsider)).to eq({})
      expect(organization.gma_representation_for(nil)).to eq({})

      listed_for_member = described_class.with_role_for(member).find(organization.id)
      listed_for_outsider = described_class.with_role_for(outsider).find(organization.id)

      expect(listed_for_member.gma_representation_for(member)[:gma_status]).to eq("pending")
      expect(listed_for_outsider.gma_representation_for(outsider)).to eq({})
    end

    it "shows outsiders only the public GMA member label once the claim is verified" do
      organization.update_columns(gma_status: "verified")

      expect(organization.gma_representation_for(outsider)).to eq(gma_member: "GMA member")
      expect(organization.gma_representation_for(member).keys).to contain_exactly(
        :gma_membership,
        :gma_status,
        :gma_chapter_name
      )
    end
  end
end
