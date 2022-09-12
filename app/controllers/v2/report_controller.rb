class V2::ReportController < MrttApiController
    skip_before_action :authenticate_user!

    def answers
        if report_params[:site_id]
            @answers = RegistrationAnswer.where(site_id: report_params[:site_id])
        else
            @answers = RegistrationAnswer.all
        end
        puts report_params
    end

    def report_params
        params.except(:format, :site).permit(:site_id)
    end
end