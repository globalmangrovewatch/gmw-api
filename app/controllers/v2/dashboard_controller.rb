class V2::DashboardController < MrttApiController
  skip_before_action :authenticate_user!

  def sites
    extent = dashboard_params[:extent]
    site_area_clause = "LEFT JOIN registration_intervention_answers ON " \
      "(sites.id = registration_intervention_answers.site_id and registration_intervention_answers.question_id = '1.3')"
    site_centroid = "ST_AsGeoJSON(ST_Centroid(sites.area)) as site_centroid"
    if extent && JSON.parse("[%s]" % extent).length == 4
      where_clause = "ST_Intersects(sites.area, ST_MakeEnvelope(%s,4326))" % extent
      @sites = Site.left_joins(:landscape).joins(site_area_clause).select("sites.*, %s" % site_centroid).where(where_clause)
    else
      @sites = Site.left_joins(:landscape).joins(site_area_clause).select("sites.*, %s" % site_centroid)
    end
  end

  private

  def dashboard_params
    params.except(:format).permit(:extent)
  end
end
