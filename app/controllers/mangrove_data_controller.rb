class MangroveDataController < ApplicationController
  before_action :set_mangrove_datum, only: [:show, :update, :destroy]

  # GET /mangrove_data
  def index
    @mangrove_data = MangroveDatum.all

    render json: @mangrove_data
  end

  # GET /mangrove_data/1
  def show
    render json: @mangrove_datum
  end

  # POST /mangrove_data
  def create
    @mangrove_datum = MangroveDatum.new(mangrove_datum_params)

    if @mangrove_datum.save
      render json: @mangrove_datum, status: :created, location: @mangrove_datum
    else
      render json: @mangrove_datum.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mangrove_data/1
  def update
    if @mangrove_datum.update(mangrove_datum_params)
      render json: @mangrove_datum
    else
      render json: @mangrove_datum.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mangrove_data/1
  def destroy
    @mangrove_datum.destroy
  end

  # Import data from CSV
  def import
    if (params[:reset])
      MangroveDatum.delete_all
    end
    MangroveDatum.import(import_params)
    head :created
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mangrove_datum
      @mangrove_datum = MangroveDatum.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def mangrove_datum_params
      params.require(:mangrove_datum).permit(:date, :location_id)
    end
end
