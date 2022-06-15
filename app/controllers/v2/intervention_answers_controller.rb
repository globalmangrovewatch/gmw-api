class V2::InterventionAnswersController < MrttApiController
    def index
        site = Site.find_by_id(params[:site_id])
        if not site
            render json: {
                "message": "Site %s not found" % params[:site_id]
            }, :status => :not_found
        else
            @answers = site.intervention_answers.order(question_id: :asc)
        end
    end

    def update
        payload = params[:_json]
        ensure_unique(payload)

        site = Site.find(params[:site_id])
        @answers = site.intervention_answers
        @answers.delete_all

        payload.each do |item|
            @answers.create(
                question_id: item[:question_id],
                answer_value: item[:answer_value]
            )
        end
        @answers = @answers.order(question_id: :asc)
    end

    def partial_update
        payload = params[:_json]
        ensure_unique(payload)

        site = Site.find(params[:site_id])
        @answers = site.intervention_answers

        payload.each do |item|
            existing_answer = @answers.where(question_id: item[:question_id]).first
            if existing_answer
                existing_answer.update(answer_value: item[:answer_value])
            else
                @answers.create(
                    question_id: item[:question_id],
                    answer_value: item[:answer_value]
                )
            end
        end
        @answers = @answers.order(question_id: :asc)
    end

    def ensure_unique(payload)
        counts = Hash.new 0

        payload.each do |item|
            counts[item[:question_id]] += 1
            if counts[item[:question_id]] > 1
                render json: {
                        "message": "%s was seen multiple times" % item[:question_id]
                    }, :status => :bad_request
            end
        end
    end

end
