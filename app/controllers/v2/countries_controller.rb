class V2::CountriesController < ApiController
  def index
    @countries = Location.unscoped
      .where(location_type: "country")
      .joins("LEFT OUTER JOIN country_regions ON country_regions.iso3 = UPPER(locations.iso)")
      .select("locations.location_id, locations.iso, locations.name, country_regions.region")
      .order("locations.name ASC")
  end
end
