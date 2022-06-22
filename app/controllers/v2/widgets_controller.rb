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
      @data = Location.joins(:species).includes(:species).where(id: params[:location_id])
    else
      @data = Location.joins(:species).includes(:species)
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
      @data = RestorationPotential.select('indicator, sum(value) as value, unit').where(year: params[:year] || 2016).group(:indicator, :unit)
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
      @data = InternationalStatus.select('indicator, location_id, value, sum(value) over () as total_value').where(location_id: params[:location_id])
    else
      @data = InternationalStatus.select('indicator, sum(value) as value').group('indicator')
      @location_id = 'worldwide'
    end
  end

    # GET /v2/widgets/ecosystem_services
    def ecosystem_service
      if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
        @location_id = params[:location_id]
        @data = EcosystemService.select('indicator, location_id, value, sum(value) over () as total_value').where(location_id: params[:location_id])
      else
        @data = EcosystemService.select('indicator, sum(value) as value').group('indicator')
        @location_id = 'worldwide'
      end
    end
end