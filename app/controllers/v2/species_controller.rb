class V2::SpeciesController < ApiController
  def index
    if (params[:location_id])
      @species = Specie.joins(:locations).where(locations: [params[:location_id]])
    else
      @species = Specie.all
    end
  end
end