class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :update, :destroy]
  # caches_action :index, :worldwide, :show

  # GET /locations
  def index
    if params.has_key?(:rank_by)
      @locations = Location.rank_by_mangrove_data_column(params[:rank_by], params[:dir], params[:start_date] || '1996', params[:end_date] || '2019', params[:location_type], params[:limit] || 5)
    else
      @locations = []
      worldwide = Location.find_by(location_id: 'worldwide')
      @locations << worldwide if worldwide
      @locations += Location.all.where.not(location_id: 'worldwide').order(name: :asc)
    end

    render json: @locations,
      status: :ok,
      adapter: :json,
      root: 'data',
      meta: { dates: Location.dates_with_data(params[:rank_by]) },
      each_serializer: LocationListSerializer
  end

  # GET /locations/worldwide
  def worldwide
    json_response(Location.worldwide)
  end

  # POST /locations
  def create
    @location = Location.new(location_params)

    if @location.save
      json_response(@location, :created)
    else
      json_response(@location.errors, :unprocessable_entity)
    end
  end

  # GET /locations/:id
  def show
    json_response(@location)
  end

  # PUT /locations/:id
  def update
    if @location.update(location_params)
      json_response(@location)
    else
      json_response(@location.errors, :unprocessable_entity)
    end
  end

  # DELETE /locations/:id
  def destroy
    @location.destroy
    head :no_content
  end

  # Import data from CSV
  def import
    if (params[:reset])
      Location.destroy_all
    end
    Location.import(import_params)
    head :created
  end

  def import_geojson
    if (params[:reset])
      Location.destroy_all
    end
    Location.import_geojson(import_params)
    head :created
  end

  private

    def set_location
      next_location = Location.find_by(iso: params[:id], location_type: 'country')
      next_location = Location.find_by(location_id: params[:id]) unless next_location

      if next_location
        @location = next_location
      else
        @location = Location.find(params[:id].to_i)
      end
    end

    def location_params
      params.permit(:name, :location_type, :iso)
    end

    def import_params
      params.permit(:file)
    end
end
