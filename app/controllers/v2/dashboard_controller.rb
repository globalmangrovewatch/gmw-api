class V2::DashboardController < MrttApiController
    skip_before_action :authenticate_user!

    def sites
        site_area_question_id = "1.3"
        site_area_clause = "LEFT JOIN registration_answers ON " +
                           "(sites.id = registration_answers.site_id and registration_answers.question_id = '%s')" % site_area_question_id
        site_centroid = "registration_answers.answer_value::json->'features'->0->'geometry'->'coordinates'->0->0 as site_centroid"
        @sites = Site.left_joins(:landscape).joins(site_area_clause).select("sites.*, %s" % site_centroid)
    end
end