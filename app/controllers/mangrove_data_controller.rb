class MangroveDataController < ApplicationController
  before_action :set_location
  before_action :set_location_mangrove_datum, only: [:show, :update, :destroy]

  # GET /locations/:location_id/mangrove_data
  def index
    json_response(@location.mangrove_data)
  end

  # GET /locations/:location_id/mangrove_data/:id
  def show
    json_response(@mangrove_datum)
  end

  # POST /locations/:location_id/mangrove_data
  def create
    @location.mangrove_data.create!(item_params)
    json_response(@location, :created)
  end

  # PUT /locations/:location_id/mangrove_data/:id
  def update
    @item.update(item_params)
    head :no_content
  end

  # DELETE /locations/:location_id/mangrove_data/:id
  def destroy
    @item.destroy
    head :no_content
  end

  private

  def item_params
    params.permit(:date)
  end

  def set_location
    @location = Location.find(params[:location_id])
  end

  def set_location_mangrove_datum
    @mangrove_datum = @location.items.find_by!(id: params[:id]) if @location
  end
end
