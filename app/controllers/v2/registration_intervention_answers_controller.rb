class V2::RegistrationInterventionAnswersController < MrttApiController
    def index
        site = Site.find_by_id!(params[:site_id])
        landscape = site.landscape
        organization_ids = landscape.organization_ids

        # Non-admin and non-members are allowed to view answers on public section of the form
        # Instead of returning: insufficient_privilege && return
        # We restrict the sections instead
        @restricted_sections = []
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            always_public_sections = ["1"]
            @restricted_sections = (
                site.section_data_visibility ?
                    site.section_data_visibility.map{
                        |key, value| value == "private" && always_public_sections.exclude?(key.split(".")[0]) ? key : nil
                    }.select{|i| i != nil} : []
            )
        end
        # proceed

        @answers = site.registration_intervention_answers.order(question_id: :asc)
    end

    def update
        payload = params[:_json]
        ensure_unique(payload)

        site = Site.find(params[:site_id])
        landscape = site.landscape
        organization_ids = landscape.organization_ids

        # admin can update any answer record
        # org member can only update answer under site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
        @answers = site.registration_intervention_answers
        @answers.delete_all

        payload.each do |item|
            @answers.create(
                question_id: item[:question_id],
                answer_value: item[:answer_value]
            )
            update_site_area(site, item)
        end
        @answers = @answers.order(question_id: :asc)
    end

    def partial_update
        payload = params[:_json]
        ensure_unique(payload)

        site = Site.find(params[:site_id])
        landscape = site.landscape
        organization_ids = landscape.organization_ids

        # admin can update any answer record
        # org member can only update answer under site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
        # proceed
        @answers = site.registration_intervention_answers

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
            update_site_area(site, item)
        end
        @answers = @answers.order(question_id: :asc)
    end

    private

    def update_site_area(site, item)
        site_area_question_id = "1.3"
        if item[:question_id] == site_area_question_id
            if item[:answer_value].key?("features")
                polygon = item[:answer_value][:features][0][:geometry]
                polygon = polygon.to_json.to_s
                polygon = RGeo::GeoJSON.decode(polygon, :json_parser => :json)
                site.update(area: polygon)
            else
                site.update(area: nil)
            end
        end
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
    