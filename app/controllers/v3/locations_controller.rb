class V3::LocationsController < V2::LocationsController
  before_action :authenticate_user!
end

