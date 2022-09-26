class V2::ReportController < MrttApiController
    skip_before_action :authenticate_user!

    def answers
        range_query = "split_part(question_id, '.', 1)::numeric between 1 and 5"
        @registration_answers = RegistrationInterventionAnswer.where(range_query)

        range_query = "split_part(question_id, '.', 1)::numeric between 6 and 9"
        @intervention_answers = RegistrationInterventionAnswer.where(range_query)

        @monitoring_answers = MonitoringAnswer.all
    end

end