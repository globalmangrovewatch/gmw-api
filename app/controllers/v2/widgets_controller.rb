class V2::WidgetsController < ApiController
  helper PivotTableHelper
  helper ApplicationHelper

  CONVERSION_UNITS = {"km2" => 0.01, "ha" => 1, "m2" => 10000}.freeze

  # GET /v2/widgets/protected-areas
  def protected_areas
    # original area data is in hectares,
    # but we want to display it in square km
    # TODO: make this configurable https://github.com/mhuggins/ruby-measurement
    @unit = CONVERSION_UNITS.keys.find { |unit| unit == params[:units].to_s } || "ha"
    @conversion_factor = CONVERSION_UNITS[@unit]

    # location_id here references location.location_id instead of location.id
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @protected_areas = WidgetProtectedAreas.joins(:location).includes(:location).where(location: {id: @location_id})

    else
      @location_id = "worldwide"
      @protected_areas = WidgetProtectedAreas.select("year, sum(total_area) as total_area, sum(protected_area) as protected_area").group("year")
    end
  end

  # POST /v2/widgets/protected-areas
  def protected_areas_import
    WidgetProtectedAreas.destroy_all
    WidgetProtectedAreas.import(params[:file])
    head :created
  end

  # GET /v2/widgets/biodiversity
  def biodiversity
    @data = if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      Location.unscope(:select).joins(:species).includes(:species).where(id: params[:location_id])
    else
      Location.unscope(:select).joins(:species).includes(:species)
    end
  end

  # GET /v2/widgets/restoration-potential
  def restoration_potential
    @year = RestorationPotential.pluck(:year).uniq.sort.reverse
    default_year = @year[0]
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @data = RestorationPotential.where(location_id: params[:location_id], year: params[:year] || default_year)
    else
      @location_id = "worldwide"
      @data = RestorationPotential.select("indicator, sum(value) as value, unit").where(year: params[:year] || default_year, indicator: ["restorable_area", "mangrove_area"]).group(:indicator, :unit)
    end
  end

  # GET /v2/widgets/degradation-and-loss
  def degradation_and_loss
    @year = DegradationTreemap.pluck(:year).uniq.sort.reverse
    default_year = @year[0]
    @labels = {
      "degraded_area" => "Non-Restorable loss mangrove area",
      "lost_area" => "Total loss",
      "mangrove_area" => "Mangrove area",
      "restorable_area" => "Restorable loss mangrove area"
    }
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @data = DegradationTreemap.where(location_id: @location_id, year: params[:year] || default_year)
      @lost_driver = @data.first
    else
      @location_id = "worldwide"
      @data = DegradationTreemap.select("a.*").from(
        DegradationTreemap.where(year: params[:year] || default_year).select("indicator, sum(value) as value").group("indicator"), :a
      )
    end
    @restorable_area = DegradationTreemap.find_by(indicator: "restorable_area")
    @degraded_area = DegradationTreemap.find_by(indicator: "degraded_area")
    @lost_area = DegradationTreemap.find_by(indicator: "lost_area")
    @mangrove_area = DegradationTreemap.find_by(indicator: "mangrove_area")
  end

  # GET /v2/widgets/blue-carbon-investment
  def blue_carbon_investment
    # TODO: make this configurable
    # TODO: global data is a bit of a hack, should be refactored
    @labels = {
      "carbon_5" => "at $5/ton",
      "carbon_10" => "at $10/ton",
      "protected" => "Protected",
      "remaining" => "Remaining"
    }

    @unit = CONVERSION_UNITS.keys.find { |unit| unit == params[:units].to_s } || "ha"
    @conversion_factor = CONVERSION_UNITS[@unit]

    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @data = BlueCarbonInvestment.select("category, to_char((area*#{@conversion_factor}), '999,999,999D9')\
       ||' (± '|| area*0.05*#{@conversion_factor} || ')' as description, location_id, area,\
       sum(area) over () as total_area").where(location_id: @location_id)
    else
      @location_id = "worldwide"
      @data = BlueCarbonInvestment.select("category, to_char((area*#{@conversion_factor}), '999,999,999D9')\
       || ' (±'|| area*0.05*#{@conversion_factor} || ')' as description,'_' as description_a, area,\
        sum(area) over () as total_area").from(BlueCarbonInvestment.select('category, sum("blue_carbon_investments".area) as area').group("category"), :a)
    end
  end

  # GET /v2/widgets/international_status
  def international_status
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @data = helpers.grid(InternationalStatus.select("indicator, location_id, value").where(location_id: params[:location_id]),
        {row_name: :location_id, column_name: :indicator,
         value_name: :indicator, field_name: :value,
         cast: {
           "ndc" => "boolean",
           "ndc_adaptation" => "boolean",
           "ndc_mitigation" => "boolean",
           "ndc_updated" => "boolean",
           "ndc_reduction_target" => "float",
           "ndc_target" => "float"
         }})
    else
      @location_id = "worldwide"
      @data = []
    end
  end

  # GET /v2/widgets/ecosystem_services
  def ecosystem_service
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @data = EcosystemService.select("indicator, location_id, value, sum(value) over () as total_value").where(
        location_id: params[:location_id]
      )
    else
      @data = EcosystemService.select("indicator, sum(value) as value").group("indicator")
      @location_id = "worldwide"
    end
  end

  # GET /v2/widgets/habitat_extent
  def habitat_extent
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @data = HabitatExtent.joins(:location).includes(:location).where(location: {id: params[:location_id]}).order("indicator, year")
      @total_area = @data.first.location.area_m2 * 0.000001 # convert to km2
      @total_lenght = @data.first.location.coast_length_m * 0.001 # convert to km
    else
      @data = HabitatExtent.joins(:location).select(
        "indicator, year, sum(value) as value"
      ).where(
        locations: {location_type: "country"}
      ).group(:indicator, :year).order(:indicator, :year)
      @location_id = "worldwide"
      metadata = Location.where(
        locations: {location_type: @location_id}
      ).first
      @total_area = metadata.area_m2 * 0.000001 # data in m convert to km2
      @total_lenght = metadata.coast_length_m * 0.001 # data in m convert to km
    end
  end

  # GET /v2/widgets/net_change
  def net_change
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @year = HabitatExtent.select("year").distinct.pluck(:year).sort
      @data = HabitatExtent.joins(:location).includes(:location).select("year, value - (COALESCE(LAG(value, 1) OVER (ORDER BY year), value)) as value, location.location_id").where(location: {id: params[:location_id]}, indicator: "habitat_extent_area").order(:indicator, :year)
      @total_area = @data.first.location.area_m2 * 0.000001 # convert to km2
      @total_lenght = @data.first.location.coast_length_m * 0.001 # convert to km
    else
      subquery = HabitatExtent.joins(:location).select(
        "indicator, year, sum(value) as value, sum(coast_length_m) as coast_length_m, sum(area_m2) as area_m2"
      ).where(
        indicator: "habitat_extent_area",
        locations: {location_type: "country"}
      ).group(:indicator, :year).order(:indicator, :year)

      @data = HabitatExtent.from(subquery, :a).select(
        "a.year, a.value - (COALESCE(LAG(a.value, 1) OVER (ORDER BY a.year), a.value)) as value, a.coast_length_m, a.area_m2"
      )

      @location_id = "worldwide"
      @total_area = @data[0].area_m2 * 0.000001 # convert to km2
      @total_lenght = @data[0].coast_length_m * 0.001 # convert to km
    end
  end

  # GET /v2/widgets/aboveground_biomass
  def aboveground_biomass
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]

      base = AbovegroundBiomass.joins(:location).includes(:location).where(location: {id: @location_id})

      @data = base.and(AbovegroundBiomass.where.not(
        indicator: ["avg", "total"]
      )).order("indicator, year")
      totals = base.and(AbovegroundBiomass.where(
        indicator: ["avg", "total"]
      )).order("indicator, year")
      @total_aboveground_biomass = totals.where(indicator: "total").map { |row| {"year" => row.year, "value" => row.value} }
      @avg_aboveground_biomass = totals.where(indicator: "avg").map { |row| {"year" => row.year, "value" => row.value} }
    else
      @data = AbovegroundBiomass.joins(:location).select(
        "indicator, year, sum(value) as value"
      ).where(
        locations: {location_type: "country"}
      ).where.not(
        indicator: ["avg"]
      ).group(:indicator, :year).order(:indicator, :year)
      @location_id = "worldwide"
      @total_aboveground_biomass = @data.where(indicator: "total").map { |row| {"year" => row.year, "value" => row.value} }
      @avg_aboveground_biomass = AbovegroundBiomass.select(
        "indicator, year, avg(value) as value"
      ).where(
        indicator: ["avg"]
      ).group(:indicator, :year).order(:indicator, :year).map { |row| {"year" => row.year, "value" => row.value} }
    end
  end

  # GET /v2/widgets/tree_height
  def tree_height
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      base = TreeHeight.joins(:location).includes(:location).where(location: {id: params[:location_id]})
      @location_id = params[:location_id]
      @data = base.and(TreeHeight.where.not(
        indicator: ["avg"]
      )).order("indicator, year")
      @avg_height = base.and(TreeHeight.where(
        indicator: ["avg"]
      )).order("indicator, year").map { |row| {"year" => row.year, "value" => row.value} }
    else
      @data = TreeHeight.joins(:location).select(
        "indicator, year, sum(value) as value"
      ).where(
        locations: {location_type: "country"}
      ).where.not(
        indicator: ["avg"]
      ).group(:indicator, :year).order(:indicator, :year)
      @location_id = "worldwide"
      @avg_height = TreeHeight.select(
        "indicator, year, avg(value) as value"
      ).where(
        indicator: ["avg"]
      ).group(:indicator, :year).order(:indicator, :year).map { |row| {"year" => row.year, "value" => row.value} }
    end
  end

  # GET /v2/widgets/blue_carbon
  def blue_carbon
    indicators = ["toc", "soc", "agb"]

    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]

      base = BlueCarbon.joins(:location).includes(:location).select(:location_id, :indicator, :value, :year).where(locations: {id: @location_id})
      @data = base.and(BlueCarbon.where.not(
        indicator: indicators
      )).order("indicator, year")

      @meta = helpers.grid(base.and(BlueCarbon.where(
        indicator: indicators
      )).order("indicator, year"),
        {row_name: :location_id, column_name: :indicator,
         value_name: :indicator, field_name: :value,
         cast: {}}).first
    else
      @location_id = "worldwide"
      base = BlueCarbon.joins(:location).select(
        "'worldwide' as location_id, indicator, year, sum(value) as value"
      ).where(
        location: {location_type: "country"}
      ).group(:indicator, :year).order(:indicator, :year)
      @data = base.where.not(
        indicator: indicators
      )
      @meta = helpers.grid(base.where(
        indicator: indicators
      ), {row_name: :location_id, column_name: :indicator,
          value_name: :indicator, field_name: :value,
          cast: {}}).first

    end
  end

  # GET /v2/widgets/mitigation_potencials
  def mitigation_potencials
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @data = MitigationPotentials.select("*").joins(:location).includes(:location).where(location: {id: @location_id})
    else
      @location_id = "worldwide"
      @data = MitigationPotentials.select("indicator, category, year, sum(value) as value").group(:indicator, :category, :year).order(:year, :category, :indicator)
    end
  end

  # GET /v2/widgets/country_ranking
  def country_ranking
    @limit = params[:limit] || 10
    @order = params[:order] || "desc"
    @range = HabitatExtent.select(:year).distinct.pluck(:year).uniq.sort
    @start_year = params[:start_year] || @range[0]
    @end_year = params[:end_year] || @range[-1]

    subquery = HabitatExtent.joins(:location).includes(:location).select("year, COALESCE(LAG(value, 1) OVER (PARTITION BY location.iso ORDER BY year ASC), value) value_prior, value, location.name, indicator, location.iso").where(location: {location_type: "country"}, indicator: "habitat_extent_area", year: [@start_year, @end_year]).order(:indicator, :year)

    @data = HabitatExtent.select("sum(value - value_prior) as value, ABS(sum(value - value_prior)) as abs_value, name,'net_change' indicator, iso").from(subquery).group(:name, :indicator, :iso).order("2 desc").limit(@limit)
  end

  # GET /v2/widgets/drivers_of_change
  def drivers_of_change
    if params.has_key?(:location_id) && params[:location_id] != "worldwide"
      @location_id = params[:location_id]
      @data = DriversOfChange.includes(:location).where location_id: @location_id
    else
      @location_id = "worldwide"
      @data = []
    end
  end
end
