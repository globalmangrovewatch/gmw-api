class V2::LocationsController < ApiController
  before_action :set_location, only: [:show, :update, :destroy]

  # GET /locations
  def index
    @locations = Location.where.not(
      location_type: "aoi"
    ).all.order(location_type: :asc, name: :asc, iso: :asc)

    @dates = Location.dates_with_data
  end

  # GET /locations/worldwide
  def worldwide
    @location = Location.worldwide
  end

  # POST /locations
  def create
    @location = Location.new(location_params)

    if @location.save
      render :create, status: :created
    else
      # json_response(@location.errors, :unprocessable_entity)
      render :create, status: :unprocessable_entity
    end
  end

  # GET /locations/:id
  def show
    data = Location.unscope(:select)
    @location = data.find_by(iso: params[:id], location_type: "country") || data.find_by(location_id: params[:id])
  end

  # PUT /locations/:id
  def update
    if @location.update(location_params)
      render :update
    else
      render :update, status: :unprocessable_entity
    end
  end

  # DELETE /locations/:id
  def destroy
    @location.destroy
    head :no_content
  end

  private

  def set_location
    next_location = Location.find_by(iso: params[:id], location_type: "country")
    next_location ||= Location.find_by(location_id: params[:id])

    @location = next_location || Location.find(params[:id].to_i)
  end

  def location_params
    params.permit(:name, :location_type, :iso)
  end

  def import_params
    params.permit(:file)
  end
end
