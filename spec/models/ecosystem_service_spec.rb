require "rails_helper"

RSpec.describe EcosystemService, type: :model do
  it { should belong_to(:location) }

  it { should validate_presence_of(:indicator) }
  it { should validate_presence_of(:value) }
end
