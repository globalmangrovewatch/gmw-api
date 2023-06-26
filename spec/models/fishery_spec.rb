require "rails_helper"

RSpec.describe Fishery, type: :model do
  it { should validate_presence_of(:indicator) }
  it { should validate_presence_of(:category) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:year) }
end
