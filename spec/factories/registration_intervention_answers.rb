FactoryBot.define do
  factory :registration_intervention_answer do
    site
    sequence(:question_id) do |n|
      Faker::Config.random = Random.new(n)
      Faker::Number.decimal l_digits: 1
    end
    answer_value do
      {
        "selectedValues" =>
          [
            "Tourism and recreation",
            "Safeguard cultural or spiritual importance",
            "Unknown",
            "None"
          ],
        "isOtherChecked" => false
      }
    end
  end
end
