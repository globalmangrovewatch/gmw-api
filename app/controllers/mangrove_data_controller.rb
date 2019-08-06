class MangroveDataController < ApplicationController
  before_action :set_location, except: [:import]
  before_action :set_mangrove_datum, only: [:show, :update, :destroy]

  # GET /mangrove_data
  def index
    json_response(@location.mangrove_datum, :ok, {
      location_coast_length_m: @location.coast_length_m
    })
  end

  # GET /mangrove_data/1
  def show
    json_response(@mangrove_datum)
  end

  # POST /mangrove_data
  def create
    @mangrove_datum = MangroveDatum.new(mangrove_datum_params)

    if @mangrove_datum.save
      json_response(@mangrove_datum, :created)
    else
      json_response(@mangrove_datum.errors, :unprocessable_entity)
    end
  end

  # PATCH/PUT /mangrove_data/1
  def update
    if @mangrove_datum.update(mangrove_datum_params)
      json_response(@mangrove_datum)
    else
      json_response(@mangrove_datum.errors, :unprocessable_entity)
    end
  end

  # DELETE /mangrove_data/1
  def destroy
    @mangrove_datum.destroy
    head :no_content
  end

  # Import data from CSV
  def import
    if (params[:reset])
      MangroveDatum.destroy_all
    end
    MangroveDatum.import(import_params)
    head :created
  end

  private

    def set_location
      # TODO: allow to search by ISO
      @location = Location.find(params[:location_id])
    end

    def set_mangrove_datum
      @mangrove_datum = @location.mangrove_datum.find_by!(id: params[:id]) if @location
    end

    def import_params
      params.permit(:file)
    end

    def mangrove_datum_params
      params.permit(:date, :location_id)
    end
end
