class V2::WidgetsController < ApiController
  def protected_areas
    @protected_areas = WidgetProtectedAreas.where(location_id: params[:location_id])
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
    if params.has_key?(:location_id) && params[:location_id] != 'worldwide'
      @data = RestorationPotential.where(location_id: params[:location_id], year: params[:year] || 2016)
    else
      @data = RestorationPotential.where(year: params[:year] || 2016)
    end
  end

  def degradation_and_loss
    @data = DegradationTreemap.where(location_id: params[:location_id], year: params[:year] || 2016)
  end

  def blue_carbon_investment
    @data = BlueCarbonInvestment.where(location_id: params[:location_id])
  end
end