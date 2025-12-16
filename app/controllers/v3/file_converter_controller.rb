class V3::FileConverterController < V2::FileConverterController
  before_action :authenticate_user!
end

