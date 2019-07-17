require 'rails_helper'

RSpec.describe MangroveDatum, type: :model do
  # Validation tests
  it { should validate_presence_of(:date) }
end
