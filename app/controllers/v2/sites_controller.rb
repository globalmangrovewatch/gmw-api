class V2::SitesController < ApiController
    def index
        @sites = Site.all
    end

    def show
        @site = Site.find(params[:id])
    end

    def create
        @site = Site.create(site_params)
    end

    def update
        @site = Site.find(params[:id])
        @site.update(site_params)
    end

    def destroy
        @site = Site.find(params[:id])
        @site.destroy
    end

    def site_params
        params.require(:site).permit(:site_name)
    end
end
