require "rails_helper"

RSpec.describe RegistrationInterventionAnswer, type: :model do
  it { should belong_to(:site) }

  describe ".with_selected_values" do
    let!(:answer_1) do
      create :registration_intervention_answer,
        question_id: "6.2",
        answer_value: {
          "selectedValues" => ["Vegetation clearance and suppression "], "isOtherChecked" => true, "otherValue" => "test"
        }
    end
    let!(:answer_2) do
      create :registration_intervention_answer,
        question_id: "6.2",
        answer_value: {
          "selectedValues" => [" Remove debris"], "isOtherChecked" => true, "otherValue" => "test"
        }
    end
    let!(:answer_3) do
      create :registration_intervention_answer,
        question_id: "4.2",
        answer_value: {
          "selectedValues" => ["Vegetation clearance and suppression"], "isOtherChecked" => true, "otherValue" => "test"
        }
    end

    it "returns correct site based on provided question_id and selected values" do
      expect(described_class.with_selected_values("6.2", ["Vegetation clearance and suppression"])).to eq([answer_1])
      expect(described_class.with_selected_values("6.2", ["Remove debris"])).to eq([answer_2])
      expect(described_class.with_selected_values("4.2", ["Vegetation clearance and suppression"])).to eq([answer_3])
      expect(described_class.with_selected_values("7.2", ["Remove debris"])).to be_empty
      expect(described_class.with_selected_values("6.2", ["RANDOM VALUE"])).to be_empty
    end

    it "adds additional results when Other is checked" do
      expect(described_class.with_selected_values("6.2", ["Vegetation clearance and suppression", "Other"]))
        .to match_array([answer_1, answer_2])
    end
  end

  describe ".with_selected_category" do
    let!(:answer_1) do
      create :registration_intervention_answer,
        question_id: "4.2",
        answer_value: [
          {"mainCauseLabel" => "Residential & commercial development",
           "mainCauseAnswers" => [{"mainCauseAnswer" => "Housing & urban areas", "levelOfDegredation" => "Moderate"}]},
          {"mainCauseLabel" => "Agriculture & aquaculture",
           "subCauses" =>
             [{"subCauseLabel" => "Marine & freshwater aquaculture",
               "subCauseAnswers" => [{"subCauseAnswer" => "Shrimp aquaculture", "levelOfDegredation" => "High"}]}]}
        ]
    end
    let!(:answer_2) do
      create :registration_intervention_answer,
        question_id: "4.2",
        answer_value: [
          {"mainCauseLabel" => "Natural system modifications",
           "subCauses" =>
             [{"subCauseLabel" => "Dams & water management/use",
               "subCauseAnswers" =>
                 [{"subCauseAnswer" => "Reduced sediment flows", "levelOfDegredation" => "High"},
                   {"subCauseAnswer" => "Reduction in flows/altered hydrology", "levelOfDegredation" => "High"}]}]},
          {"mainCauseLabel" => "Climate change & severe weather",
           "mainCauseAnswers" =>
             [{"mainCauseAnswer" => "Sea level change", "levelOfDegredation" => "Low"},
               {"mainCauseAnswer" => "Storms & flooding", "levelOfDegredation" => "Moderate"}]}
        ]
    end

    it "returns correct results" do
      expect(described_class.with_selected_category("4.2", "Residential & commercial development"))
        .to eq([answer_1])
      expect(described_class.with_selected_category("4.2", "Natural system modifications"))
        .to eq([answer_2])
      expect(described_class.with_selected_category("4.2", "RANDOM ANSWER")).to be_empty
      expect(described_class.with_selected_category("6.2", "Residential & commercial development")).to be_empty
    end
  end
end
