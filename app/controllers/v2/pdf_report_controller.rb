class V2::PdfReportController < MrttApiController
    def pdf_report_formatter
        pdf_report_formatter = {
            "1.1a" => { 
                "name" => "Project start date",
                "type" => "date",
                "category" => "01 Site Details and Location"
            },
            "1.1b" => {
                "name" => "Does this project have an end date?",
                "type" => "boolean",
                "category" => "01 Site Details and Location"
            },
            "1.1c" => {
                "name" => "Project end date",
                "type" => "date",
                "category" => "01 Site Details and Location"
            },
            "1.2" => { 
                "name" => "What country/countries is the site located in?",
                "type" => "1.2 countries",
                "category" => "01 Site Details and Location"
            },
            "1.3" => { 
                "name" => "What is the overall site area?",
                "type" => "1.3 map",
                "category" => "01 Site Details and Location"
            },
            "2.1" => {
                "name" => "Which stakeholders are involved in the project activities?",
                "type" => "2.1 stakeholders",
                "category" => "02 Site Background"
            },
            "2.2" => {
                "name" => "What was the management status of the site immediately before the project started?",
                "type" => "string",
                "category" => "02 Site Background"
            },
            "2.3" => {
                "name" => "Are management activities at the site recognized in statutory or customary laws?",
                "type" => "string",
                "category" => "02 Site Background"
            },
            "2.4" => {
                "name" => "Name of the formal management area the site is contained within (if relevant)?",
                "type" => "string",
                "category" => "02 Site Background"
            },
            "2.5" => {
                "name" => "How would you describe the protection status of the site immediately before the project started?",
                "type" => "multiselect",
                "category" => "02 Site Background"
            },
            "2.6" => {
                "name" => "Are the stakeholders involved in project activities able to influence site management rules?",
                "type" => "string",
                "category" => "02 Site Background"
            },
            "2.7" => {
                "name" => "What best describes the governance arrangement of the site immediately before the project started?",
                "type" => "multiselect",
                "category" => "02 Site Background"
            },
            "2.8" => {
                "name" => "What was the land tenure of the site immediately before the project started?",
                "type" => "multiselect",
                "category" => "02 Site Background"
            },
            "2.9" => {
                "name" => "Are customary rights to land within the site recognised in national law?",
                "type" => "string",
                "category" => "02 Site Background"
            },
            "3.1" => {
                "name" => "What are the ecological aim(s) of the project activities at the site?",
                "type" => "multiselect",
                "category" => "03 Restoration Aims"
            },
            "3.2" => {
                "name" => "What are the socio-economic aim(s) of project activities at the site?",
                "type" => "multiselect",
                "category" => "03 Restoration Aims"
            },
            "3.3" => {
                "name" => "What are the other aim(s) of project activities at the site?",
                "type" => "multiselect",
                "category" => "03 Restoration Aims"
            },
            "4.1" => {
                "name" => "Is the cause(s) of mangrove loss or degradation at the site known?",
                "type" => "boolean",
                "category" => "04 Causes of Decline"
            },
            "4.2" => {
                "name" => "What were the major cause(s) of mangrove loss or degradation at the site?",
                "type" => "4.2 4.3 causes",
                "category" => "04 Causes of Decline"
            }, 
            "5.1" => {
                "name" => "Have mangroves naturally occurred at the site previously?",
                "type" => "string",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.2" => {
                "name" => "Has mangrove restoration/rehabilitation been attempted at the site previously?",
                "type" => "string",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.2a" => {
                "name" => "What year was restoration/rehabilitation last attempted at the site?",
                "type" => "string",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.2b" => {
                "name" => "What biophysical interventions were previously attempted at the site?",
                "type" => "multiselect",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.2c" => {
                "name" => "If the last restoration/rehabilitation attempt was unsuccessful, please specify why this was the case?",
                "type" => "multiselect",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.3" => {
                "name" => "Was the site assessed before the current project activities were started?",
                "type" => "string",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.3a" => {
                "name" => "How was the assessment undertaken?",
                "type" => "multiselect",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.3b" => {
                "name" => "Has the site been compared to a reference site?",
                "type" => "string",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.3c" => {
                "name" => "What year were mangroves lost from this site?",
                "type" => "string",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.3d" => {
                "name" => "Is natural regeneration apparent at the site?",
                "type" => "string",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.3e" => {
                "name" => "What mangrove species were present at the site?",
                "type" => "list",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.3f" => {
                "name" => "What was the species composition of mangroves at the site?",
                "type" => "5.3f species",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.3g" => {
                "name" => "What physical site measurements were taken?",
                "type" => "5.3g measurements",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.4" => {
                "name" => "Was a pilot/test intervention conducted?",
                "type" => "string",
                "category" => "05 Pre-Restoration Assessment"
            },
            "5.5" => {
                "name" => "Was external expertise or guidance consulted on how to best restore the site?",
                "type" => "string",
                "category" => "05 Pre-Restoration Assessment"
            },
            "6.1" => {
                "name" => "Which stakeholders undertook the project activities at the site?",
                "type" => "6.1 10.2 stakeholders",
                "category" => "06 Site Interventions"
            },
            "6.2" => {
                "name" => "What biophysical interventions were used to restore/rehabilitate the site?",
                "type" => "multiselect",
                "category" => "06 Site Interventions"
            },
            "6.2a" => {
                "name" => "What was the duration of the biophysical interventions?",
                "type" => "6.2a daterange",
                "category" => "06 Site Interventions"
            },
            "6.2b" => {
                "name" => "What mangrove species were used? What was the source of seeds/propagules or seedlings?",
                "type" => "6.2b species",
                "category" => "06 Site Interventions"
            },
            "6.2c" => {
                "name" => "Were mangrove-associated species planted?",
                "type" => "6.2c planted",
                "category" => "06 Site Interventions"
            },
            "6.3" => {
                "name" => "Did local participants receive restoration training?",
                "type" => "string",
                "category" => "06 Site Interventions"
            },
            "6.3a" => {
                "name" => "What type of organisations provided the restoration training?",
                "type" => "multiselect",
                "category" => "06 Site Interventions"
            },
            "6.4" => {
                "name" => "Were there other activities implemented to address the causes of decline at the site?",
                "type" => "multiselect",
                "category" => "06 Site Interventions"
            },
            "7.1" => {
                "name" => "What type of support was provided for the project activities conducted at the site?",
                "type" => "multiselect",
                "category" => "07 Costs"
            },
            "7.2" => {
                "name" => "What is the main finance mechanism used to fund the project interventions at the site?",
                "type" => "7.2 funding",
                "category" => "07 Costs"
            },
            "7.3" => {
                "name" => "What funders provided monetary support?",
                "type" => "7.3 funders",
                "category" => "07 Costs"
            },
            "7.4" => {
                "name" => "What was the total cost of the project activities at the site?",
                "type" => "7.4 cost total",
                "category" => "07 Costs"
            },
            "7.5" => {
                "name" => "What was the breakdown of the costs of the project activities?",
                "type" => "7.5 cost breakdown",
                "category" => "07 Costs"
            },
            "7.5a" => {
                "name" => "What was the approximate percentage split in expenditure between the different biophysical interventions and/or community activities?",
                "type" => "7.5a cost percentage",
                "category" => "07 Costs"
            },
            "7.6" => {
                "name" => "What non-monetised contributions were made to the project activities at the site?",
                "type" => "multiselect",
                "category" => "07 Costs"
            },
            "8.1" => {
                "name" => "What date was this management status and effectiveness assessment conducted?",
                "type" => "date",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.2" => {
                "name" => "Which stakeholders currently manage the site?",
                "type" => "multiselect",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.3" => {
                "name" => "Are these stakeholders involved in the project activities able to influence management rules at the site?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.4" => {
                "name" => "Has any aspect of the management status of the site changed since the start of the project activities?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.4a" => {
                "name" => "What is the current management status of the site?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.4b" => {
                "name" => "Are management activities at the site recognized in statutory or customary laws?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.4c" => {
                "name" => "Name of the formal management area the site is contained within (if relevant)?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.5" => {
                "name" => "Has the protected status of the site changed since the start of the project activities?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.5a" => {
                "name" => "How would you currently describe the protection status of the site?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.6" => {
                "name" => "What is the main finance mechanism used to fund ongoing site management?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.7" => {
                "name" => "Is the current budget or funds used to support on-going management activities at the site sufficient?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.8" => {
                "name" => "Do those responsible for on-going management at the site (e.g., staff, community associations, management groups) have sufficient capacity and resources to enforce the rules and regulations?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.9" => {
                "name" => "Is there an effective strategy or approach for ensuring benefits from the site are shared equitably among local stakeholders?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "8.10" => {
                "name" => "Is the site consciously managed to adapt to climate change?",
                "type" => "string",
                "category" => "08 Management Status & Effectiveness"
            },
            "9.1" => {
                "name" => "What date was this socioeconomic and governance status and outcomes assessment conducted?",
                "type" => "date",
                "category" => "09 Sociological and Governance Status and Outcomes"
            },
            "9.2" => {
                "name" => "Has the governance arrangement of the site changed since the start of the project activities?",
                "type" => "string",
                "category" => "09 Sociological and Governance Status and Outcomes"
            },
            "9.2a" => {
                "name" => "What best describes the current governance arrangement of the site?",
                "type" => "multiselect",
                "category" => "09 Sociological and Governance Status and Outcomes"
            },
            "9.3" => {
                "name" => "Has the tenure arrangement of the site changed since the start of the project activities?",
                "type" => "string",
                "category" => "09 Sociological and Governance Status and Outcomes"
            },
            "9.3a" => {
                "name" => "What is the current land ownership of the site?",
                "type" => "multiselect",
                "category" => "09 Sociological and Governance Status and Outcomes"
            },
            "9.3b" => {
                "name" => "Are customary rights to land within the site recognised in national law?",
                "type" => "string",
                "category" => "09 Sociological and Governance Status and Outcomes"
            },
            "9.4" => {
                "name" => "What were the socioeconomic outcomes of the project activities at the site? Please fill the measurement data for the selected socioeconomic outcomes.",
                "type" => "9.4 social outcomes",
                "category" => "09 Sociological and Governance Status and Outcomes"
            },
            "9.5" => {
                "name" => "To what extent do you feel the socio-economic aims have been achieved?",
                "type" => "string",
                "category" => "09 Sociological and Governance Status and Outcomes"
            },
            "10.1" => {
                "name" => "What were the dates of the ecological monitoring being reported on?",
                "type" => "VOID",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.1a" => {
                "name" => "Ecological monitoring start date:",
                "type" => "date",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.1b" => {
                "name" => "Ecological monitoring end date:",
                "type" => "date",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.2" => {
                "name" => "Which stakeholders carried out the ecological monitoring?",
                "type" => "6.1 10.2 stakeholders",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.3" => {
                "name" => "Was there an increase in mangrove area?",
                "type" => "string",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.3a" => {
                "name" => "What was the mangrove area pre and post restoration activities at the site?",
                "type" => "TODO",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.4" => {
                "name" => "Was there an improvement in mangrove condition?",
                "type" => "string",
                "category" => "10 Ecological Status and Outcomes"
            },
            # This question does not seem to exist?
            "10.4a" => {
                "name" => "Was there an improvement in mangrove condition?",
                "type" => "VOID",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.5" => {
                "name" => "Is natural regeneration apparent, with mangroves establishing at the site?",
                "type" => "string",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.6" => {
                "name" => "What was the percentage survival of the planted mangrove seedlings or propagules?",
                "type" => "TODO",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.6a" => {
                "name" => "If survival was low, is the cause known?",
                "type" => "TODO",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.7" => {
                "name" => "What mangrove ecological outcomes were monitored",
                "type" => "10.7 eco outcomes",
                "category" => "10 Ecological Status and Outcomes"
            },
            "10.8" => {
                "name" => "To what extent do you feel the ecological aims have been achieved?",
                "type" => "string",
                "category" => "10 Ecological Status and Outcomes"
            },
        }
    
    def pdf_order_by_section
        pdf_order_by_section = [
            "Site Details and Location" => 1,
            "Site Background" => 2,
            "Restoration Aims" => 3,
            "Causes of Decline" => 4,
            "Pre-Restoration Assessment" => 5,
            "Site Interventions" => 6,
            "Costs" => 7
        ]
    end

        return pdf_report_formatter
    end

    def format_answers(site, question_id, answer_value, pdf_answers)
        pdf_format = pdf_report_formatter
        if pdf_format.key?(question_id)
            site[:value] = answer_value
            site[:name] = pdf_format[question_id]["name"]
            case pdf_format[question_id]["type"]
            when "string"
                site[:value] = [answer_value.to_s]
            when "list"
                site[:value] = answer_value
            when "date"
                site[:value] = [DateTime.parse(site[:value]).to_date.to_s]
            when "boolean"
                if site[:value]
                    site[:value] = ["Yes"]
                else
                    site[:value] = ["No"]
                end
            when "multiselect"
                select_array = []
                site[:value]["selectedValues"].each { |x|
                    select_array.push(x)
                }
                if site[:value]["isOtherChecked"]
                    select_array.push("Other: " + site[:value]["otherValue"])
                end
                if select_array.empty?
                    pdf_answers.delete(question_id)
                else
                    site[:value] = select_array
                end
            when "1.2 countries"
                country_array = []
                site[:value].each { |x|
                    country_array.push(x["properties"]["country"])
                }
                site[:value] = country_array
            when "1.3 map"
                # site[:value] = generate_mapbox_url(answer_value)
                puts answer_value
            when "2.1 stakeholders"
                stakeholder_array = []
                site[:value].each { |x|
                    stakeholder_name = x["stakeholderName"]
                    stakeholder_type = x["stakeholderType"]
                    stakeholder_array.push({name: stakeholder_name, type: stakeholder_type})
                }
                site[:value] = stakeholder_array
            # TODO expand this further
            when "4.2 4.3 causes"
                causes_array = []
                site[:value].each { |x|
                    causes_array.push(x["mainCauseLabel"])
                    if x["mainCauseAnswers"].present?
                        x["mainCauseAnswers"].each { |y|
                            main_cause_answer = y["mainCauseAnswer"]
                            level_of_degradation = y["levelOfDegredation"]
                            causes_array.push("#{main_cause_answer}, Level of Degredation: #{level_of_degradation}")
                        }
                    end
                    if x["subCauses"].present?
                        x["subCauses"].each { |y|
                            causes_array.push(y["subCauseLabel"])
                            y["subCauseAnswers"].each { |z|
                                sub_cause_answer = z["subCauseAnswer"]
                                level_of_degradation = z["levelOfDegredation"]
                                causes_array.push("#{sub_cause_answer}, Level of Degredation: #{level_of_degradation}")
                            }
                        }                    
                    end
                }
                site[:value] = causes_array
            when "5.3f species"
                species_array = []
                site[:value].each { |x|
                    species_type = x["mangroveSpeciesType"]
                    percentage = x["percentageComposition"]
                    species_array.push("Species: #{species_type}, Percent: #{percentage.to_s}")
                }
                site[:value] = species_array
            when "5.3g measurements"
                measurements_array = []
                site[:value].each { |x|
                    if x["measurementValue"].present?
                        measurement_type = x["measurementType"]
                        measurement_value = x["measurementValue"]
                    measurements_array.push("Type: #{measurement_type}, Value: #{measurement_value}")
                    end
                }
                site[:value] = measurements_array
            when "6.1 10.2 stakeholders"
                stakeholder_array = []
                site[:value].each { |x|
                    stakeholder = x["stakeholder"]
                    stakeholder_type = x["stakeholderType"]
                    stakeholder_array.push("Name: #{stakeholder}, Type: #{stakeholder_type}")
                }
                site[:value] = stakeholder_array
            # TODO - needs testing
            when "6.2a daterange"
                date_array = []
                if site[:value]["startDate"].present?
                    start_date = DateTime.parse(x["startDate"]).to_date.to_s
                    date_array.push("Start Date: #{start_date}")
                end
                if site[:value]["endDate"].present?
                    end_date = DateTime.parse(x["endDate"]).to_date.to_s
                    date_array.push("End Date: #{end_date}")
                end
                site[:value] = date_array
            when "6.2b species"
                species_array = []
                site[:value].each { |x|
                    type = x["type"]
                    species_array.push(type)
                    if x["seed"]["checked"]
                        seed_source = x["seed"]["source"][0]
                        seed_count = x["seed"]["count"]
                        species_array.push("Seed Source: #{seed_source}, Count: #{seed_count}")
                    end
                    if x["propagule"]["checked"]
                        propagule_source = x["propagule"]["source"][0]
                        propagule_count = x["propagule"]["count"]
                        species_array.push("Propagule Source: #{propagule_source}, Count: #{propagule_count}")
                    end
                }
                site[:value] = species_array
            when "6.2c planted"
                planted_array = []
                site[:value].each { |x|
                    type = x["type"]
                    count = x["count"]
                    source = x["source"]
                    if x["purpose"]["other"].present?
                        purpose = "Other: " + x["purpose"]["other"]
                    else
                        purpose = x["purpose"]["purpose"]
                    end
                    planted_array.push([type, count, source, purpose])
                }
                site[:value] = planted_array
            when "7.2 funding"
                site[:value] = ["Funding Type: " + site[:value]["fundingType"]]
            when "7.3 funders"
                funders_array = []
                site[:value].each { |x|
                    funder_name = x["funderName"]
                    funder_type = x["funderType"]
                    percentage = x["percentage"]
                    funders_array.push([funder_name, funder_type, percentage])
                }
                site[:value] = funders_array
            when "7.4 cost total"
                cost = site[:value]["cost"]
                currency = site[:value]["currency"]
                site[:value] = [cost.to_s + " " + currency]
            when "7.5 cost breakdown"
                cost_array = []
                site[:value].each { |x|
                    if x["id"].present?
                        cost_type = x["costType"]
                        cost = x["cost"]
                        currency = x["currency"]
                        cost_array.push("#{cost_type}, #{cost}#{currency}")
                    end
                }
                if cost_array.empty?
                    pdf_answers.delete(question_id)
                else
                    site[:value] = cost_array
                end
            when "7.5a cost percentage"
                cost_array = []
                site[:value].each { |x|
                    intervention = x["intervention"]
                    percentage = x["percentage"]
                    cost_array.push("#{intervention}, #{percentage}%")
                }
                site[:value] = cost_array
            when "9.4 social outcomes"
                outcomes_array = []
                site[:value].each { |x|
                    outcome = []
                    main_label = "#{x["mainLabel"]}: #{x["secondaryLabel"]}"
                    sub_label = x["child"]
                    type = "Type: #{x["type"]}"
                    outcome.push(main_label, sub_label, type)
                    if x["trend"].present?
                        trend = "Trend: #{x["trend"]}"
                        outcome.push(trend)
                    end
                    if x["measurement"].present?
                        measurement = "Measurement: #{x["measurement"]} #{x["unit"]}"
                        comparison = "Comparison: #{x["comparison"]} = #{x["value"]}"
                        outcome.push(measurement, comparison)
                    end
                    outcome.push("Linked aims:")
                    x["linkedAims"].each { |aim| outcome.push(aim) }
                    outcomes_array.push(outcome)
                }
                site[:value] = outcomes_array
            when "10.7 eco outcomes"
                outcomes_array = []
                site[:value].each { |x|
                    outcome = []
                    main_label = "#{x["mainLabel"]}: #{x["secondaryLabel"]}"
                    sub_label = x["child"]
                    type = "#{x["indicator"]}: #{x["metric"]}"
                    outcome.push(main_label, sub_label, type)
                    if x["measurement"].present? || x["measurementComparison"].present?
                        measurement = "Measurement: #{x["measurement"]} #{x["unit"]}"
                        comparison = "Comparison: #{x["comparison"]} = #{x["measurementComparison"]}"
                        outcome.push(measurement, comparison)
                    end
                    outcome.push("Linked aims:")
                    x["linkedAims"].each { |aim| outcome.push(aim) }
                    outcomes_array.push(outcome)
                }
                site[:value] = outcomes_array
            when "VOID"
                pdf_answers.delete(question_id)
            else
                site[:value] = ["TODO"]
            end             
        
        else
            
        end
    end

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
        landscape = site.landscape
        organization_ids = landscape.organization_ids
        registration_intervention_answers = site.registration_intervention_answers

        # Non-admin and non-members are allowed to view answers on public section of the form
        # Instead of returning: insufficient_privilege && return
        # We restrict the sections instead
        @restricted_sections = []
        if not (current_user.is_admin || current_user.is_member_of_any(organization_ids))
            @restricted_sections = (
                site.section_data_visibility ?
                    site.section_data_visibility.map{|key, value| value == "private" ? key : nil }.select{|i| i != nil} :
                    []
            )
        end

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
            if not @restricted_sections.include?(answer.question_id.split(".")[0])
                monitoring_events[answer.uuid]["answers"][answer.question_id] = answer.answer_value
            end
        }

        monitoring_answers = []
        monitoring_events.each { |key, value|
            monitoring_answers.push(value)
        }
        return site.id, registration_intervention_answers, monitoring_answers, landscape
    end

    def report_params
        params.except(:format, :site).permit(:site_id)
    end

    def sort_answers(registration_intervention_answers, monitoring_answers)
        pdf_format = pdf_report_formatter
        registration_intervention_answers.each { |reg_answer|
            if reg_answer.answer_value.present? || reg_answer.answer_value == false

                question_id = reg_answer.question_id
                answer_value = reg_answer.answer_value

                if pdf_format.key?(question_id)
                    category = pdf_format[question_id]["category"]
                end

                pdf_answers = @pdf_reg_answers[category]
                site = @pdf_reg_answers[category][reg_answer.question_id]
                
                # puts "Site: " + site.to_s
                # puts "Question ID: " + question_id.to_s
                # puts "Value " + answer_value.to_s
                # puts "PDF Answers" + pdf_answers.to_s

                format_answers(site, question_id, answer_value, pdf_answers)
            end
        }
        monitoring_answers.each { |mon_answer|
        @pdf_mon_answers[mon_answer["uuid"]]["monitoring_date"] = mon_answer["monitoring_date"].to_date.to_s
            mon_answer["answers"].each { |question_id, answer_value|
                if answer_value.present? || answer_value == false

                    if pdf_format.key?(question_id)
                        category = pdf_format[question_id]["category"]
                    end

                    pdf_answers = @pdf_mon_answers
                    site = @pdf_mon_answers[mon_answer["uuid"]]["answers"][category][question_id]

                    format_answers(site, question_id, answer_value, pdf_answers)
                end
            }
        }
    end

    def export_pdf_single_site
        site = Site.find(params[:site_id])
        @pdf_reg_answers = Hash.new { |h, k| h[k] = h.dup.clear }
        @pdf_mon_answers = Hash.new { |h, k| h[k] = h.dup.clear }
        @single_site = []
        @answer_array = []
        site_row = {}
        
        site_id, registration_intervention_answers, monitoring_answers, landscape = get_answers_by_site(site.id)
        # answers = monitoring_answers.uuid
        
        # puts pdf_format
        @pdf_landscape = landscape.landscape_name
        sort_answers(registration_intervention_answers, monitoring_answers)

        @pdf_reg_answers.each { |key, value| 
            @pdf_reg_answers[key] = value.sort
        }
        @pdf_reg_answers = @pdf_reg_answers.sort
              
        @pdf_mon_answers.each { |uuid, mon_list|
            mon_list["answers"].each { |key, value|
                mon_list["answers"][key] = value.sort
            }
        }
        @pdf_mon_answers = @pdf_mon_answers.sort_by { |uuid, mon_list|
            mon_list["monitoring_date"]
        }
        # @pdf_mon_answers = @pdf_mon_answers.sort_by { |uuid, mon_list|
        #     mon_list
        # }

        # category_order = pdf_order_by_section
        # @pdf_reg_answers = @pdf_reg_answers.sort_by { |key, value| category_order[key] }
        
        # puts @pdf_reg_answers

        site_row["site_id"] = site.id
        site_row["site_name"] = site.site_name

        # puts site_row["1.3"]

        # answers.each { |answer|
        #     site_row[answer.question_id] = answer.answers
        #     puts answers.question_id
        # }
        # site.monitoring_answers.each { |answer|
        #     item["answer_value"] = answer.uuid
        #     @answer_array.push(item)
        # }
        @single_site.push(site_row)

        # Site.all.each { |site|
        #     registration_intervention_answers.each { |answer|
        #         site_row[answer.question_id] = answer.answer_value
        #     }

        #     # generate Mapbox url
        #     # site_row["site_map"] = generate_mapbox_url(site_row["1.3"])

            
        # }

        # Set up PDFKit options
        # header_html_path = URI("#{Rails.root}/app/views/v2/pdf_report/single_site_header.html")
        footer_html_path = URI("#{Rails.root}/app/views/v2/pdf_report/single_site_footer.html")
        options = {
            :margin_top => '0.7in',
            :margin_right => '0.5in',
            :margin_bottom => '0.7in',
            :margin_left => '0.5in',
            :enable_local_file_access => true,
            :quiet => false,
            # :header_html => header_html_path,
            :header_left => 'REPORT',
            :header_line => true,
            :header_spacing => '5',
            :footer_html => footer_html_path,
            :footer_spacing => '2'
        }

        # Render the HTML template as a string
        # html = render_to_string(:template => 'v2/pdf_report/sites.pdf', :formats => 'html', :layout => false)
        html = render_to_string(:template => 'v2/pdf_report/single_site', :formats => [:html])

        # Create a new PDFKit object and convert the HTML to a PDF file
        kit = PDFKit.new(html, options)
        kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf_report.css"
        pdf_file = kit.to_file("#{Rails.root}/tmp/single_site.pdf")

        # Send the generated PDF file as a download
        send_file pdf_file.path, :type => 'application/pdf', :disposition => 'attachment', :filename => 'single_site.pdf'
        # Render the HTML (temporary solution)
        # render(:template => 'v2/pdf_report/single_site', :formats => [:html])
        # html = render_to_string(:template => 'v2/pdf_report/single_site', :formats => [:html])
        # kit = PDFKit.new(html, :page_size => 'Letter')
        # pdf = kit.to_pdf
    end

    def export_pdf
        @all_site_rows = []
        Site.all.each { |site|
            site_row = {}
            site_id, registration_intervention_answers, monitoring_answers = get_answers_by_site(site.id)

            site_row["site_id"] = site.id
            site_row["site_name"] = site.site_name

            # registration_intervention_answers.each { |answer|
            #     site_row[answer.question_id] = answer.answer_value
            # }

            # generate Mapbox url
            site_row["site_map"] = generate_mapbox_url(site_row["1.3"])
            puts site_row["1.3"]

            @all_site_rows.push(site_row)
        }

        # Set up PDFKit options
        options = {
            :margin_top => '0.5in',
            :margin_right => '0.5in',
            :margin_bottom => '0.5in',
            :margin_left => '0.5in'
        }

        # Render the HTML template as a string
        # html = render_to_string(:template => 'v2/pdf_report/sites.pdf', :formats => 'html', :layout => false)
        html = render_to_string(:template => 'v2/pdf_report/sites', :formats => [:html])
        # render(:template => 'v2/pdf_report/sites', :formats => [:html])
        # Create a new PDFKit object and convert the HTML to a PDF file
        # File.write("#{Rails.root}/tmp/sites.pdf", '')
        pdf_file = PDFKit.new(html, options).to_file("#{Rails.root}/tmp/sites.pdf")
        # kit = PDFKit.new(html, :page_size => 'Letter')
        # pdf = kit.to_pdf
        # file = kit.to_file("#{Rails.root}/tmp/sites.pdf")

        # Send the generated PDF file as a download
        send_file pdf_file.path, :type => 'application/pdf', :disposition => 'attachment', :filename => 'sites.pdf'
        # send_data(pdf, type: 'application/pdf', disposition: 'attachment', filename: 'sites.pdf')
    end

    def generate_mapbox_url(geojson)
        url = nil
        if geojson.present?         
            geojson = geojson["features"][0]
            geojson = reduce_precision_geojson(geojson)
            token = ENV["MAPBOX_ACCESS_TOKEN"]
            url = "https://api.mapbox.com/v4/mapbox.satellite/geojson(%s)/%s/150x75@2x.png?access_token=%s" % [geojson.to_json, "auto", token]
        end
        return url
    end

    def reduce_precision_geojson(geojson)
        geometry = geojson["geometry"]
        coordinates = geometry["coordinates"]
        coordinates_o = coordinates[0]
        coordinates_o.each { |coord|
            coord[0] = coord[0].truncate(2)
            coord[1] = coord[1].truncate(2)
        }
        return geojson
    end

end