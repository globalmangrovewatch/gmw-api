require "rails_helper"

RSpec.describe OrganizationJoinRequest, type: :model do
  describe "validations" do
    it "rejects a request from someone who is already a member" do
      organization = create(:organization)
      user = create(:user)
      OrganizationsUsers.create!(organization: organization, user: user, role: "org-user")

      request = build(:organization_join_request, organization: organization, user: user)

      expect(request).not_to be_valid
      expect(request.errors[:user]).to include("is already a member of this organization")
    end

    it "rejects a second pending request and enforces that in the database" do
      request = create(:organization_join_request)
      duplicate = build(:organization_join_request, organization: request.organization, user: request.user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user]).to include("already has a pending request")
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows a new request after the previous one was rejected" do
      request = create(:organization_join_request, status: "rejected")

      expect(build(:organization_join_request, organization: request.organization, user: request.user)).to be_valid
    end
  end

  describe "#requester_name" do
    it "hides a name that contains an email address" do
      request = build(:organization_join_request, user: build(:user, name: "ana.requester@wetlands.org"))

      expect(request.requester_name).to be_nil
    end
  end

  describe "#review" do
    let(:reviewer) { create(:user) }

    it "approves the request and creates an org-user membership in one transaction" do
      request = create(:organization_join_request)

      expect(request.review("approved", reviewer: reviewer)).to be(true)

      request.reload
      membership = OrganizationsUsers.find_by!(organization: request.organization, user: request.user)
      expect(request.status).to eq("approved")
      expect(request.reviewed_by).to eq(reviewer)
      expect(request.reviewed_at).to be_present
      expect(membership.role).to eq("org-user")
    end

    it "rolls back the decision when the membership cannot be created" do
      request = create(:organization_join_request)
      allow(OrganizationsUsers).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique.new("duplicate"))

      expect {
        request.review("approved", reviewer: reviewer)
      }.to raise_error(ActiveRecord::RecordNotUnique)

      expect(request.reload.status).to eq("pending")
      expect(request.reviewed_at).to be_nil
      expect(OrganizationsUsers.where(user: request.user)).to be_empty
    end

    it "rejects a request without creating a membership" do
      request = create(:organization_join_request)

      expect(request.review("rejected", reviewer: reviewer)).to be(true)

      expect(request.reload.status).to eq("rejected")
      expect(OrganizationsUsers.where(user: request.user)).to be_empty
    end

    it "leaves an existing membership role unchanged" do
      request = create(:organization_join_request)
      OrganizationsUsers.create!(organization: request.organization, user: request.user, role: "org-admin")

      expect(request.review("approved", reviewer: reviewer)).to be(true)

      membership = OrganizationsUsers.find_by!(organization: request.organization, user: request.user)
      expect(membership.role).to eq("org-admin")
    end

    it "does not review a request that is no longer pending" do
      request = create(:organization_join_request, status: "rejected")

      expect(request.review("approved", reviewer: reviewer)).to be(false)
      expect(request.reload.status).to eq("rejected")
      expect(OrganizationsUsers.where(user: request.user)).to be_empty
    end
  end
end
