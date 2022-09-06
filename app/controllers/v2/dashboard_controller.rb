class V2::DashboardController < MrttApiController
    skip_before_action :authenticate_user!

    def sites
        site_area_question_id = "1.3"
        site_area_clause = "LEFT JOIN registration_answers ON " +
                           "(sites.id = registration_answers.site_id and registration_answers.question_id = '%s')" % site_area_question_id
        @sites = Site.left_joins(:landscape).joins(site_area_clause).select("sites.*, registration_answers.answer_value as site_area")
    end
end
