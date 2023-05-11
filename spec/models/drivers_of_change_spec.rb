require "rails_helper"

RSpec.describe DriversOfChange, type: :model do
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:variable) }
  it { should validate_presence_of(:primary_driver) }
end
