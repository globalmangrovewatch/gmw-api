require "rails_helper"

RSpec.describe RegistrationInterventionAnswer, type: :model do
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

  describe "site area sync" do
    let(:site) { create(:site, area: nil) }

    it "syncs sites.area when question 1.3 is saved" do
      create(:registration_intervention_answer, site: site, question_id: "1.3", answer_value: geojson_answer)

      expect(site.reload.area).to be_present
    end

    it "clears sites.area when question 1.3 is destroyed" do
      answer = create(:registration_intervention_answer, site: site, question_id: "1.3", answer_value: geojson_answer)
      expect(site.reload.area).to be_present

      answer.destroy

      expect(site.reload.area).to be_nil
    end

    it "does not sync sites.area for other questions" do
      create(
        :registration_intervention_answer,
        site: site,
        question_id: "6.2",
        answer_value: {"selectedValues" => ["Remove debris"], "isOtherChecked" => false}
      )

      expect(site.reload.area).to be_nil
    end

    it "keeps the existing area when geometry sync fails" do
      existing_area = create(:site).area
      site.update!(area: existing_area)

      allow(Site).to receive(:area_geometry_from_geojson_answer).and_return(nil)

      create(:registration_intervention_answer, site: site, question_id: "1.3", answer_value: geojson_answer)

      expect(site.reload.area).to eq(existing_area)
    end

    it "clears sites.area when question 1.3 is explicitly emptied" do
      create(:registration_intervention_answer, site: site, question_id: "1.3", answer_value: geojson_answer)
      expect(site.reload.area).to be_present

      answer = site.registration_intervention_answers.find_by!(question_id: "1.3")
      answer.update!(answer_value: {"type" => "FeatureCollection", "features" => []})

      expect(site.reload.area).to be_nil
    end
  end
end
