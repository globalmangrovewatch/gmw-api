class V3::SpeciesController < V2::SpeciesController
  before_action :authenticate_user!
end

