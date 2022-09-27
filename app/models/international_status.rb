class InternationalStatus < ApplicationRecord
    belongs_to :location

    enum indicator: {
    "pledge_type":"pledge_type",
    "base_years":"base_years",
    "target_years":"target_years",
    "ndc_target":"ndc_target",
    "ndc_reduction_target":"ndc_reduction_target",
    "ndc_target_url":"ndc_target_url",
    "pledge_summary":"pledge_summary",
    "ndc_blurb":"ndc_blurb",
    "ndc":"ndc",
    "ndc_updated":"ndc_updated",
    "ndc_mitigation":"ndc_mitigation",
    "ndc_adaptation":"ndc_adaptation",
    "ipcc_wetlands_suplement":"ipcc_wetlands_suplement",
    "frel":"frel",
    "year_frel":"year_frel",
    "fow":"fow",
    }
end
