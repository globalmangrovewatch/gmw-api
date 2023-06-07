require "rails_helper"

RSpec.describe NationalDashboard, type: :model do
  it { should validate_presence_of(:indicator) }
  it { should validate_presence_of(:year) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:unit) }
end
