class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :update, :destroy]

  # GET /locations
  def index
    @locations = Location.all
    json_response(@locations)
  end

  # POST /locations
  def create
    @location = Location.create!(location_params)
    json_response(@location, :created)
  end

  # GET /locations/:id
  def show
    json_response(@location)
  end

  # PUT /locations/:id
  def update
    @location.update(location_params)
    head :no_content
  end

  # DELETE /locations/:id
  def destroy
    @location.destroy
    head :no_content
  end

  # Import data from CSV
  def import
    if (params[:reset])
      Location.delete_all
    end
    Location.import(import_params)
    head :created
  end

  private

  def location_params
    # whitelist params
    params.permit(:name, :location_type, :iso)
  end

  def import_params
    # whitelist params
    params.permit(:file)
  end

  def set_location
    @location = Location.find(params[:id])
  end
end
