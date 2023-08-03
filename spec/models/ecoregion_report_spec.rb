require "rails_helper"

RSpec.describe EcoregionReport, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:url) }
end
