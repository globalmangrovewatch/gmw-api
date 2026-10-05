require "rails_helper"

RSpec.describe Site, type: :model do
  it { should belong_to(:landscape) }
  it { should have_many(:registration_intervention_answers).dependent(:destroy) }
  it { should have_many(:monitoring_answers).dependent(:destroy) }

  describe ".at_organizations" do
    let(:organization) { create(:organization) }
    let!(:site) { create(:site, landscape: create(:landscape, organizations: [organization])) }
    let!(:other_site) { create(:site) }

    it "returns sites at the given organizations" do
      expect(described_class.at_organizations(organization.organization_name)).to eq([site])
    end
  end

  describe ".area_geometry_from_geojson_answer" do
    let(:geojson_answer) do
      {
        "type" => "FeatureCollection",
        "features" => [
          {
            "type" => "Feature",
            "geometry" => {
              "type" => "Polygon",
              "coordinates" => [[[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]]
            },
            "properties" => {}
          }
        ]
      }
    end

    it "returns geometry for a valid FeatureCollection" do
      expect(described_class.area_geometry_from_geojson_answer(geojson_answer)).to be_present
    end

    it "returns nil when features are missing" do
      expect(described_class.area_geometry_from_geojson_answer({"type" => "FeatureCollection"})).to be_nil
    end
  end

  describe ".with_registration_intervention_answer" do
    let(:answer) do
      create :registration_intervention_answer,
        question_id: "6.2",
        answer_value: {
          "selectedValues" => ["Vegetation clearance and suppression"], "isOtherChecked" => true, "otherValue" => "test"
        }
    end
    let(:other_answer) do
      create :registration_intervention_answer,
        question_id: "6.2",
        answer_value: {
          "selectedValues" => ["Remove debris"], "isOtherChecked" => true, "otherValue" => "test"
        }
    end
    let!(:site) { create :site, registration_intervention_answers: [answer] }
    let!(:other_site) { create :site, registration_intervention_answers: [other_answer] }

    it "returns sites with the given answer" do
      expect(described_class.with_registration_intervention_answer(answer.question_id, ["Vegetation clearance and suppression"]))
        .to eq([site])
    end
  end
end
