class WidgetDataController < ApplicationController

  def mangrove_coverage
    data = MangroveDatum.mangrove_coverage(params[:country], params[:location_id])
    json_response(data)
  end

  def mangrove_net_change
    data = MangroveDatum.mangrove_net_change(params[:country], params[:location_id])
    json_response(data)
  end

end
