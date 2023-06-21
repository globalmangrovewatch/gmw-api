require "rails_helper"

RSpec.describe FloodProtection, type: :model do
  it { should validate_presence_of(:indicator) }
  it { should validate_presence_of(:period) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:unit) }
end
