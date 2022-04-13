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
    @locations = Location.joins(:species).where(id: params[:location_id])
  end

  def restoration_potential
    @data = RestorationPotential.where(location_id: params[:location_id], year: params[:year] || 2016)
  end

  def degradation_and_loss
    @data = DegradationTreemap.where(location_id: params[:location_id], year: params[:year] || 2016)
  end
end