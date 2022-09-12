class MitigationPotentials < ApplicationRecord
    belongs_to :location
    enum indicator: {
        "Reduce deforestation":"Reduce deforestation", 
        "Reforestation (Tropics)":"Reforestation (Tropics)",
        "Forest Management (Global)":"Forest Management (Global)", 
        "Grassland and savanna fire mgmt":"Grassland and savanna fire mgmt", 
        "Reduce peatland degradation and conversion":"Reduce peatland degradation and conversion", 
        "Reduce mangrove loss":"Reduce mangrove loss",
        "Mangrove Restoration":"Mangrove Restoration",
    }
    enum category: {
        "Mangrove":"Mangrove", 
        "Other":"Other", 
    }
end
