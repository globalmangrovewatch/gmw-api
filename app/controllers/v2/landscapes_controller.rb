class V2::LandscapesController < MrttApiController
    def index
        @landscapes = Landscape.all
    end

    def show
        @landscape = Landscape.find(params[:id])
    end

    def create
        @landscape = Landscape.create(landscape_params)
    end

    def update
        @landscape = Landscape.find(params[:id])
        @landscape.update(landscape_params)
    end

    def destroy
        @landscape = Landscape.find(params[:id])
        @landscape.destroy
    end

    def landscape_params
        params.require(:landscape).permit(:landscape_name)
    end
end
