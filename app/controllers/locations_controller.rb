class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :update, :destroy]

  # GET /locations
  def index
    @locations = []
    worldwide = Location.find_by(location_id: 'worldwide')
    @locations << worldwide if worldwide
    @locations += Location.all.where.not(location_id: 'worldwide').order(name: :asc)
    json_response(@locations)
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

  private

    def set_location
      @location = Location.find(params[:id])
    end

    def location_params
      params.permit(:name, :location_type, :iso)
    end

    def import_params
      params.permit(:file)
    end
end
