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
end