class V2::SpeciesController < ApiController
  def index
    @species = if params[:location_id]
      Specie.joins(:locations).where(locations: [params[:location_id]])
    else
      Specie.all
    end
  end
end
