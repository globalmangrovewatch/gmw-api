require "rails_helper"

RSpec.describe FisheryMitigationPotential, type: :model do
  it { should validate_presence_of(:indicator_type) }
  it { should validate_presence_of(:indicator) }
  it { should validate_presence_of(:value) }
end
