class V2::SitesController < MrttApiController
    def index
        @sites = Site.left_joins(:registration_answers, :intervention_answers)
                    .select("sites.*, " \
                            "greatest(max(registration_answers.updated_at), " \
                                "max(intervention_answers.updated_at)) as section_last_updated").group(:id)
    end

    def show
        @site = Site.find(params[:id])
    end

    def create
        @site = Site.create!(site_params)
    end

    def update
        @site = Site.find(params[:id])
        @site.update!(site_params)
    end

    def destroy
        @site = Site.find(params[:id])
        @site.destroy
    end

    def site_params
        params.require(:site).permit(:site_name, :landscape_id)
    end
end
