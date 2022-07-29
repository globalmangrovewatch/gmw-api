class AbovegroundBiomass < ApplicationRecord
    belongs_to :location
    enum indicator: ["total","avg","0-50","50-100","100-150","150-250","250-1500"]
end
