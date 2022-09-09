include PivotTableHelper
class V2::WidgetsController < ApiController
  
   # GET /v2/widgets/protected-areas
  def protected_areas
    # original area data is in hectares, 
    # but we want to display it in square km 
    # TODO: make this configurable https://github.com/mhuggins/ruby-measurement
    @conversion_factor = 1
    @unit = params[:units] || 'ha'
    if params.has_key?(:units)
      @conversion_factor = case params[:units]
        when 'km2' then 0.001
        when 'ha' then  1
        when 'm' then  10000
        else 1
      end
    end
    # location_id here references location.location_id instead of location.id
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @protected_areas = WidgetProtectedAreas.where(location_id: params[:location_id])
      @location_id = params[:location_id]
    else
      @location_id = 'worldwide'
      @protected_areas = WidgetProtectedAreas.select('year, sum(total_area) as total_area, sum(protected_area) as protected_area').group('year')
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
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @data = Location.unscope(:select).joins(:species).includes(:species).where(id: params[:location_id])
    else
      @data = Location.unscope(:select).joins(:species).includes(:species)
    end
  end

  # GET /v2/widgets/restoration-potential
  def restoration_potential
    @year = RestorationPotential.pluck(:year).uniq.sort.reverse
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = RestorationPotential.where(location_id: params[:location_id], year: params[:year] || 2016)
    else
      @location_id = 'worldwide'
      @data = RestorationPotential.select('indicator, sum(value) as value, unit').where(year: params[:year] || 2016, indicator: ['restorable_area','mangrove_area'] ).group(:indicator, :unit)
    end
    
  end

  # GET /v2/widgets/degradation-and-loss
  def degradation_and_loss
    @year = DegradationTreemap.pluck(:year).uniq.sort.reverse
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = DegradationTreemap.where(location_id: params[:location_id], year: params[:year] || 2016)
      @lost_driver = @data.first
    else
      @location_id = 'worldwide'
      @data = DegradationTreemap.select('a.*').from(DegradationTreemap.where(year: params[:year] || 2016).select('indicator, sum(value) as value').group('indicator'), :a)
    end

    @degraded_area = DegradationTreemap.find_by(indicator: 'degraded_area')
    @lost_area = DegradationTreemap.find_by(indicator: 'lost_area')
    @mangrove_area = DegradationTreemap.find_by(indicator: 'mangrove_area')
  end

  # GET /v2/widgets/blue-carbon-investment
  def blue_carbon_investment
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = BlueCarbonInvestment.select('category, description, location_id, area, sum(area) over () as total_area').where(location_id: params[:location_id])
    else
      @data = BlueCarbonInvestment.select("category, CASE WHEN category = 'remaining' THEN '' \
              WHEN category  = 'carbon_10' THEN 'Global extent of investible blue carbon (ha) is '||area||' (at $10/ton)' \
              WHEN category  = 'protected' THEN '' \
              WHEN category  = 'carbon_5' THEN 'Global extent of investible blue carbon (ha) is '||area||' (at $5/ton)' \
              END description, area, sum(area) over () as total_area").from(BlueCarbonInvestment.select('category, sum("blue_carbon_investments".area) as area').group('category'), :a)
      @location_id = 'worldwide'
    end
  end

  # GET /v2/widgets/international_status
  def international_status
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = helpers.grid(InternationalStatus.select('indicator, location_id, value').where(location_id: params[:location_id]), 
      { :row_name => :location_id, :column_name => :indicator, 
        :value_name => :indicator, :field_name => :value})
    else
      @location_id = 'worldwide'
      @data = PivotTableHelper.grid(InternationalStatus.select(
        "indicator, 'worldwide' as location_id, '-' as value").group('indicator'), 
      { :row_name => :location_id, :column_name => :indicator, 
        :value_name => :indicator, :field_name => :value})
      
    end
  end

  # GET /v2/widgets/ecosystem_services
  def ecosystem_service
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = EcosystemService.select('indicator, location_id, value, sum(value) over () as total_value').where(
        location_id: params[:location_id]
        )
    else
      @data = EcosystemService.select('indicator, sum(value) as value').group('indicator')
      @location_id = 'worldwide'
    end
  end

  # GET /v2/widgets/habitat_extent
  def habitat_extent
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = HabitatExtent.joins(:location).includes(:location
            ).where(location: {id: params[:location_id]}).order('indicator, year')
      @total_area = @data.first.location.area_m2 * 0.000001 # convert to km2
      @total_lenght = @data.first.location.coast_length_m * 0.001 # convert to km
    else
      @data = HabitatExtent.joins(:location).select(
        'indicator, year, sum(value) as value'
        ).where(
          locations: {location_type: 'country'}
        ).group(:indicator, :year
        ).order(:indicator,:year)
      @location_id = 'worldwide'
      metadata = Location.where(
        locations: {location_type: @location_id}
        ).first
      @total_area = metadata.area_m2 * 0.000001 # data in m convert to km2
      @total_lenght =metadata.coast_length_m * 0.001 # data in m convert to km
    end
  end

  # GET /v2/widgets/net_change
  def net_change
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = HabitatExtent.joins(:location).includes(:location
            ).select('year, COALESCE(LAG(value, 1) OVER (ORDER BY year), value) value_prior, value, location.location_id'
            ).where(location: {id: params[:location_id]}, indicator: 'habitat_extent_area'
            ).order(:indicator,:year)
      @total_area = @data.first.location.area_m2 * 0.000001 # convert to km2
      @total_lenght = @data.first.location.coast_length_m * 0.001 # convert to km
    else
      subquery = HabitatExtent.joins(:location).select(
        'indicator, year, sum(value) as value, sum(coast_length_m) as coast_length_m, sum(area_m2) as area_m2'
        ).where(
          indicator: 'habitat_extent_area',
          locations: {location_type: 'country'}
        ).group(:indicator, :year
        ).order(:indicator,:year)
        
      @data = HabitatExtent.from(subquery, :a
      ).select(
        'a.year, COALESCE(LAG(a.value, 1) OVER (ORDER BY a.year), a.value) value_prior, a.value, a.coast_length_m, a.area_m2'
        )
      
      @location_id = 'worldwide'
      @total_area = @data[0].area_m2  # convert to km2
      @total_lenght = @data[0].coast_length_m * 0.001 # convert to km
    end
  end

  # GET /v2/widgets/aboveground_biomass
  def aboveground_biomass
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      base = AbovegroundBiomass.joins(:location).includes(:location
      ).where(location: {id: params[:location_id]}
      )
      @location_id = params[:location_id]
      @data = base.and(AbovegroundBiomass.where.not(
        indicator: ['avg', 'total']
      )).order('indicator, year')
      totals = base.and(AbovegroundBiomass.where(
        indicator: ['avg', 'total']
      )).order('indicator, year')
      @total_aboveground_biomass = totals.where(indicator: 'total'
                                  ).map { |row| {'year'=> row.year, 'value'=> row.value}}
      @avg_aboveground_biomass = totals.where(indicator: 'avg'
                                  ).map { |row| {'year'=> row.year, 'value'=> row.value}}
    else
      @data = AbovegroundBiomass.select(
        'indicator, year, sum(value) as value'
        ).where(
          locations: {location_type: 'country'}
        ).where.not(
          indicator: ['avg']
        ).group(:indicator, :year
        ).order(:indicator,:year)
      @location_id = 'worldwide'
      @total_aboveground_biomass = @data.where(indicator: 'total'
      ).map { |row| {'year'=> row.year, 'value'=> row.value}}
      @avg_aboveground_biomass = AbovegroundBiomass.select(
        'indicator, year, avg(value) as value'
        ).where(
          indicator: ['avg']
        ).group(:indicator, :year
        ).order(:indicator,:year).map { |row| {'year'=> row.year, 'value'=> row.value}}
    end
  end

  # GET /v2/widgets/tree_height
  def tree_height
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      base = TreeHeight.joins(:location).includes(:location
      ).where(location: {id: params[:location_id]}
      )
      @location_id = params[:location_id]
      @data = base.and(TreeHeight.where.not(
              indicator: ['avg']
            )).order('indicator, year')
      @avg_height = base.and(TreeHeight.where(
        indicator: ['avg']
      )).order('indicator, year'
      ).map { |row| {'year'=> row.year, 'value'=> row.value}}
    else
      @data = TreeHeight.select(
        'indicator, year, sum(value) as value'
        ).where(
          locations: {location_type: 'country'}
        ).where.not(
          indicator: ['avg']
        ).group(:indicator, :year
        ).order(:indicator,:year)
      @location_id = 'worldwide'
      @avg_height = TreeHeight.select(
        'indicator, year, avg(value) as value'
        ).where(
          indicator: ['avg']
        ).group(:indicator, :year
        ).order(:indicator,:year
        ).map { |row| {'year'=> row.year, 'value'=> row.value}}
    end
  end

  # GET /v2/widgets/blue_carbon
  def blue_carbon
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = BlueCarbon.joins(:location).includes(:location
            ).where(location: {id: params[:location_id]}
            ).and(BlueCarbon.where.not(
              indicator: ['blue_carbon_area']
            )).order('indicator, year')
    else
      @data = BlueCarbon.select(
        'indicator, year, sum(value) as value'
        ).where(
          locations: {location_type: 'country'}
        ).where.not(
          indicator: ['blue_carbon_area']
        ).group(:indicator, :year
        ).order(:indicator,:year)
      @location_id = 'worldwide'
    end
  end
end