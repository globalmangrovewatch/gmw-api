require "rails_helper"

RSpec.describe Ecoregion, type: :model do
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:indicator) }
  it { should validate_presence_of(:category) }
end
