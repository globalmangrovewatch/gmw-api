class WidgetDataController < ApplicationController

  def mangrove_coverage
    data = MangroveDatum.mangrove_coverage(params[:country], params[:location_id])
    json_response(data)
  end

end
