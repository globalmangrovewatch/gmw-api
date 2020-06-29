class MangroveDataController < ApplicationController
  before_action :set_location, except: [:worldwide, :rank, :import]
  before_action :set_mangrove_datum, only: [:show, :update, :destroy]
  # caches_action :index, :worldwide, :show

  # GET /locations/:location_id/mangrove_data
  def index
    if params.has_key?(:rank_by)
      mangrove_datum = @location.mangrove_datum.rank_by(params[:rank_by], params[:dir], params[:dir], params[:start_date] || '1996', params[:end_date] || '2019', params[:limit] || 5)
    else
      mangrove_datum = @location.mangrove_datum
    end

    json_response(mangrove_datum, :ok, {
      location_coast_length_m: @location.coast_length_m,
      dates: @location.mangrove_datum.dates_with_data(params[:rank_by])
    })
  end

  # GET /locations/worldwide/mangrove_data
  def worldwide
    json_response(Location.worldwide.mangrove_datum, :ok, {
      location_coast_length_m: Location.worldwide.coast_length_m,
      dates: Location.worldwide.mangrove_datum.dates_with_data(nil)
    })
  end

  # GET /locations/:location_id/mangrove_data/1
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
      next_location = Location.find_by(iso: params[:location_id])

      if next_location
        @location = next_location
      else
        @location = Location.find_by(id: params[:location_id].to_i)
      end
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
