module UserProfileRole
  OTHER = "other"

  OPTIONS = [
    "scientist",
    "academic",
    "ngo",
    "government_policy",
    "natural_resource_manager",
    "industry",
    "education",
    "legal_enforcement",
    OTHER
  ].freeze

  LABELS = {
    "scientist" => "Scientist",
    "academic" => "Academic",
    "ngo" => "NGO",
    "government_policy" => "Government / Policy",
    "natural_resource_manager" => "Natural Resource Managers",
    "industry" => "Industry",
    "education" => "Education (student or educator)",
    "legal_enforcement" => "Legal / Enforcement",
    OTHER => "Other"
  }.freeze
end
