class V2::ReportController < MrttApiController
    skip_before_action :authenticate_user!

    def answers
        # @answers = [
        #     {
        #         "question_id": "1.1"
        #     }
        # ]
        @answers = RegistrationAnswer.all
    end
end