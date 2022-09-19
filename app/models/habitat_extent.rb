class HabitatExtent < ApplicationRecord
    belongs_to :location

    attr_accessor :cum_sum
end
