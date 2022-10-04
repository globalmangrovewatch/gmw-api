class V2::MonitoringAnswersController < MrttApiController

    def index
        site = Site.find_by_id!(params[:site_id])
        landscape = site.landscape
        organization_ids = landscape.organization_ids

        # admin can show any answer record
        # org member can only show answer under site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
        # proceed

        @monitoring_forms = site.monitoring_answers.select("distinct(uuid), form_type, monitoring_date")
    end

    def index_per_form
        site = Site.find_by_id!(params[:site_id])
        uuid = params[:uuid]
        landscape = site.landscape
        organization_ids = landscape.organization_ids

        # admin can show any answer record
        # org member can only show answer under site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
        # proceed

        # test form existence
        form = site.monitoring_answers.find_by!(uuid: uuid)

        @uuid = uuid
        @form_type = form.form_type
        @answers = site.monitoring_answers.where(uuid: uuid).order(question_id: :asc)
        @restricted_sections = (
            site.section_data_visibility ?
                site.section_data_visibility.map{|key, value| value == "private" ? key : nil }.select{|i| i != nil} :
                []
        )
    end

    def create
        answers = params[:answers]
        form_type = params[:form_type]
        ensure_unique(answers)

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

        uuid = SecureRandom.uuid
        date = get_monitoring_date(answers, form_type)

        @answers = site.monitoring_answers
        answers.each do |answer|
            @answers.create(
                uuid: uuid,
                form_type: form_type,
                monitoring_date: date,
                question_id: answer[:question_id],
                answer_value: answer[:answer_value]
            )
        end

        @uuid = uuid
        @form_type = form_type
        @answers = @answers.where(uuid: uuid).order(question_id: :asc)
    end

    def update_per_form
        uuid = params[:uuid]
        answers = params[:answers]
        form_type = params[:form_type]
        ensure_unique(answers)

        site = Site.find_by_id!(params[:site_id])
        landscape = site.landscape
        organization_ids = landscape.organization_ids

        # admin can update any answer record
        # org member can only update answer under site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
        # proceed

        # test form existence
        form = site.monitoring_answers.find_by!(uuid: uuid)

        @answers = site.monitoring_answers.where(uuid: uuid)
        @answers.delete_all

        date = get_monitoring_date(answers, form_type)

        answers.each do |answer|
            @answers.create(
                uuid: uuid,
                form_type: form_type,
                monitoring_date: date,
                question_id: answer[:question_id],
                answer_value: answer[:answer_value]
            )
        end

        @uuid = uuid
        @form_type = form_type
        @answers = @answers.where(uuid: uuid).order(question_id: :asc)
    end

    def delete
        uuid = params[:uuid]
        
        site = Site.find_by_id!(params[:site_id])
        landscape = site.landscape
        organization_ids = landscape.organization_ids

        # admin can update any answer record
        # org member can only update answer under site that belongs to landscape
        #   that is associated to the org they are member of
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            insufficient_privilege && return
        end
        # proceed

        # test form existence
        form = site.monitoring_answers.find_by!(uuid: uuid)

        @answers = site.monitoring_answers.where(uuid: uuid)
        @answers.delete_all
    end

    private

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

    def get_monitoring_date(answers, form_type)
        form_types = {
            "managementStatusAndEffectiveness" => "8.1",
            "socioeconomicGovernanceStatusAndOutcomes" => "9.1",
            "ecologicalStatusAndOutcomes" => "10.1a"
        }
        monitoring_date_question_id = form_types[form_type]

        answers.each do |answer|
            return answer[:answer_value] if answer[:question_id] == monitoring_date_question_id
        end
        if monitoring_date_question_id
            render json: {
                "message": "Monitoring date (%s) is expected but not received." % monitoring_date_question_id
            }, :status => :bad_request
        else
            render json: {
                "message": "Unknown Monitoring form type (%s)." % form_type
            }, :status => :bad_request 
        end
    end

end
