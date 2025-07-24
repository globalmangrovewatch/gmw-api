class RegistrationInterventionAnswer < ApplicationRecord
  QUESTIONS = {
    "3.1" => [
      "Increase mangrove area",
      "Improve mangrove condition/halt or reduce degradation",
      "Increase mangrove species richness",
      "Offset mangrove loss from another area",
      "Habitat protection",
      "Increase native fauna/wildlife",
      "Increase native flora/vegetation (non-mangrove)",
      "Reduce invasive species",
      "Increase ecological resilience",
      "Increase habitat connectivity",
      "Restore hydrological connectivity",
      "Improve sediment dynamics",
      "Improve nutrient cycling",
      "Increase carbon storage and sequestration",
      "None",
      "Unknown",
      "Other"
    ],
    "3.2" => [
      "Enhance fisheries/restore fishing grounds",
      "Provide sustainable timber resources",
      "Provide sustainable non-timber products",
      "Improve water quality",
      "Prevent or ameliorate pollution",
      "Coastal storm or flood protection",
      "Erosion control or coastal stability",
      "Carbon offsets/trading",
      "Tourism and recreation",
      "Land reclamation",
      "Generate employment and income",
      "Promote women's equal representation and participation in employment",
      "Safeguard cultural or spiritual importance",
      "Safeguard traditional practises",
      "Increase food security",
      "Secure management rights and land tenure",
      "Improve local community health",
      "Coastal beautification or aesthetic value",
      "Support local community natural resource management institutions",
      "Encourage community involvement",
      "Education/raise environmental awareness",
      "Sustainable financing",
      "None",
      "Unknown",
      "Other"
    ],
    "4.2" => [
      "Residential & commercial development",
      "Agriculture & aquaculture",
      "Energy production & mining",
      "Transportation & service corridors",
      "Biological resource use",
      "Human intrusions & disturbance",
      "Natural system modifications",
      "Invasive & other problematic species, genes & diseases",
      "Pollution",
      "Geological events",
      "Climate change & severe weather",
      "Other options"
    ],
    "6.2" => [
      "Restore hydrology - excavate channels",
      "Restore hydrology - remove or breach aquaculture pond walls",
      "Restore hydrology - clear channel blockages",
      "Restore hydrology - reconnection of upstream flows restricted by dams, road crossings etc.",
      "Trap sediments (e.g., with fence barriers)",
      "Reduce wave energy (e.g., bamboo walls, offshore reefs, breakwaters)",
      "Reprofile and change the elevation of the soil, relative to sea level",
      "Activities to reduce salinity",
      "Exclusion fences",
      "Vegetation clearance and suppression",
      "Remove debris",
      "Remove seaweed or algae from seedlings",
      "Remove excess sand/sediment",
      "Planting",
      "Broadcast collected propagules onto an incoming tide",
      "Large scale broadcasting of propagules from the air or boats",
      "Assisted natural regeneration",
      "None",
      "Other"
    ],
    "6.4" => [
      "Livelihood activities",
      "Securing tenure arrangement",
      "Management activities",
      "Strengthening mangrove governance",
      "Environmental education",
      "Formal mangrove protection",
      "Training and capacity building",
      "None",
      "Other"
    ]
  }.freeze

  belongs_to :site

  scope :answer_for_site, ->(question_id, site_id) do
    where(question_id: question_id, site_id: site_id)
      .pluck(Arel.sql("ARRAY(SELECT TRIM(REPLACE(jsonb_array_elements(answer_value -> 'selectedValues')::text, '\"', '')))"))
      .flatten
      .compact
      .uniq
  end

  scope :category_for_site, ->(question_id, site_id) do
    where(question_id: question_id, site_id: site_id)
      .pluck(Arel.sql("ARRAY[(jsonb_array_elements(answer_value) ->> 'mainCauseLabel')]::text[]"))
      .flatten
      .compact
      .uniq
  end

  scope :with_selected_values, ->(question_id, selected_values) do
    query = where(question_id: question_id)
      .where("(ARRAY(SELECT TRIM(REPLACE(elem::text, '\"', '')) FROM jsonb_array_elements(answer_value -> 'selectedValues') elem) && ARRAY[:values]::text[])",
        values: Array.wrap(selected_values))
    query = query.or(where(question_id: question_id).where("answer_value ->> 'isOtherChecked' = 'true'")) if "Other".in? selected_values
    query
  end

  scope :with_selected_category, ->(question_id, selected_categories) do
    where(question_id: question_id)
      .from("registration_intervention_answers, jsonb_array_elements(answer_value) as answer")
      .where("ARRAY[(answer ->> 'mainCauseLabel')]::text[] && ARRAY[:values]", values: Array.wrap(selected_categories))
      .distinct
  end
end
