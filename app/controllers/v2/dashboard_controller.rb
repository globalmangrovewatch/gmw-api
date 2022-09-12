class V2::DashboardController < MrttApiController
    skip_before_action :authenticate_user!

    def sites
        @sites = Site.left_joins(:landscape)
    end
end