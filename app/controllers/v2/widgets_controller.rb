class V2::WidgetsController < ApiController
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

  def protected_areas_import
    WidgetProtectedAreas.destroy_all
    WidgetProtectedAreas.import(params[:file])
    head :created
  end

  def biodiversity
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @data = Location.joins(:species).includes(:species).where(id: params[:location_id])
    else
      @data = Location.joins(:species).includes(:species)
    end
  end

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

  def blue_carbon_investment
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = BlueCarbonInvestment.select('category, description, location_id, area, sum(area) over () as total_area').where(location_id: params[:location_id])
    else
      @data = BlueCarbonInvestment.select('category, description, area, sum(area) over () as total_area').from(BlueCarbonInvestment.select('category, description, sum("blue_carbon_investments".area) as area').group('category, description'), :a)
      @location_id = 'worldwide'
    end
  end

  def international_status
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @location_id = params[:location_id]
      @data = InternationalStatus.select('indicator, description, location_id, area, sum(area) over () as total_area').where(location_id: params[:location_id])
    else
      @data = InternationalStatus.select('indicator, sum(value) as value').group('indicator')
      @location_id = 'worldwide'
    end
  end
end