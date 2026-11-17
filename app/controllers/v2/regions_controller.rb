class V2::RegionsController < ApiController
  def index
    render json: CountryRegion.where(region: CountryRegion::REGIONS).distinct.order(:region)
      .pluck(:region)
  end
end
