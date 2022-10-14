class V2::ReportController < MrttApiController
    skip_before_action :authenticate_user!

    def answers_by_site
        site_id = report_params[:site_id]
        @site_id, @registration_intervention_answers, @monitoring_answers = get_answers_by_site(site_id)
    end

    def answers
        @answers = []
        Site.all.each { |site|
            site_id, registration_intervention_answers, monitoring_answers = get_answers_by_site(site.id)
            @answers.push({
                "site_id" => site_id,
                "registration_intervention_answers" => registration_intervention_answers,
                "monitoring_answers" => monitoring_answers
            })
        }
    end

    def get_answers_by_site(site_id)
        site = Site.find(site_id)
        registration_intervention_answers = site.registration_intervention_answers

        monitoring_events = {}
        site.monitoring_answers.each { |answer|
            if not monitoring_events.key?(answer.uuid)
                monitoring_events[answer.uuid] = {
                    "uuid" => answer.uuid,
                    "form_type" => answer.form_type,
                    "monitoring_date" => answer.monitoring_date,
                    "answers" => {}
                }
            end
            monitoring_events[answer.uuid]["answers"][answer.question_id] = answer.answer_value
        }

        monitoring_answers = []
        monitoring_events.each { |key, value|
            monitoring_answers.push(value)
        }
        return site.id, registration_intervention_answers, monitoring_answers
    end

    def report_params
        params.except(:format, :site).permit(:site_id)
    end
end