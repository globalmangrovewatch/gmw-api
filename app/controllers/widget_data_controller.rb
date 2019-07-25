class WidgetDataController < ApplicationController
  
  def mangrove_coverage
    data = MangroveDatum.mangrove_coverage 
    json_response(data)
  end

end
