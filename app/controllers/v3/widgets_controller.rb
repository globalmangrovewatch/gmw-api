class V3::WidgetsController < V2::WidgetsController
  before_action :authenticate_user!
end
