class V2::PdfReportController < MrttApiController
    def pdf_report_formatter
        pdf_report_formatter = {
            "1.1a" => { 
                "name" => "Project start date",
                "type" => "date"
            },
            "1.1b" => {
                "name" => "Does this project have an end date?",
                "type" => "boolean"
            },
            "1.1c" => {
                "name" => "Project end date",
                "type" => "date"
            },
            "1.2" => { 
                "name" => "What country/countries is the site located in?",
                "type" => "1.2 countries"
            },
            "1.3" => { 
                "name" => "What is the overall site area?",
                "type" => "TODO - Mapbox geolocation"
            },
            "2.1" => {
                "name" => "Which stakeholders are involved in the project activities?",
                "type" => "2.1 stakeholders"
            },
            "2.2" => {
                "name" => "What was the management status of the site immediately before the project started?",
                "type" => "string"
            },
            "2.3" => {
                "name" => "Are management activities at the site recognized in statutory or customary laws?",
                "type" => "string"
            },
            "2.4" => {
                "name" => "Name of the formal management area the site is contained within (if relevant)?",
                "type" => "string"
            },
            "2.5" => {
                "name" => "How would you describe the protection status of the site immediately before the project started?",
                "type" => "multiselect"
            },
            "2.6" => {
                "name" => "Are the stakeholders involved in project activities able to influence site management rules?",
                "type" => "string"
            },
            "2.7" => {
                "name" => "What best describes the governance arrangement of the site immediately before the project started?",
                "type" => "multiselect"
            },
            "2.8" => {
                "name" => "What was the land tenure of the site immediately before the project started?",
                "type" => "multiselect"
            },
            "2.9" => {
                "name" => "Are customary rights to land within the site recognised in national law?",
                "type" => "string"
            },
            "3.1" => {
                "name" => "What are the ecological aim(s) of the project activities at the site?",
                "type" => "multiselect"
            },
            "3.2" => {
                "name" => "What are the socio-economic aim(s) of project activities at the site?",
                "type" => "multiselect"
            },
            "3.3" => {
                "name" => "What are the other aim(s) of project activities at the site?",
                "type" => "multiselect"
            },
            "4.1" => {
                "name" => "Is the cause(s) of mangrove loss or degradation at the site known?",
                "type" => "boolean"
            },
            "4.2" => {
                "name" => "What were the major cause(s) of mangrove loss or degradation at the site?",
                "type" => "TODO"
            },
            "4.3" => {
                "name" => "Rate the magnitude of impact of the cause(s) of decline selected in the previous question, on mangrove loss and degradation - High, Moderate, Low",
                "type" => "TODO"
            },
            "5.1" => {
                "name" => "Have mangroves naturally occurred at the site previously?",
                "type" => "string"
            },
            "5.2" => {
                "name" => "Has mangrove restoration/rehabilitation been attempted at the site previously?",
                "type" => "string"
            },
            "5.2a" => {
                "name" => "What year was restoration/rehabilitation last attempted at the site?",
                "type" => "string"
            },
            "5.2b" => {
                "name" => "What biophysical interventions were previously attempted at the site?",
                "type" => "multiselect"
            },
            "5.2c" => {
                "name" => "If the last restoration/rehabilitation attempt was unsuccessful, please specify why this was the case?",
                "type" => "multiselect"
            },
            "5.3" => {
                "name" => "Was the site assessed before the current project activities were started?",
                "type" => "string"
            },
            "5.3a" => {
                "name" => "How was the assessment undertaken?",
                "type" => "multiselect"
            },
            "5.3b" => {
                "name" => "Has the site been compared to a reference site?",
                "type" => "string"
            },
            "5.3c" => {
                "name" => "What year were mangroves lost from this site?",
                "type" => "string"
            },
            "5.2d" => {
                "name" => "Is natural regeneration apparent at the site?",
                "type" => "string"
            },
            "5.3e" => {
                "name" => "What mangrove species were present at the site?",
                "type" => "list"
            },
            "5.3f" => {
                "name" => "What was the species composition of mangroves at the site?",
                "type" => "5.3f species"
            },
            "5.3g" => {
                "name" => "What physical site measurements were taken?",
                "type" => "5.3g measurements"
            },
            "5.4" => {
                "name" => "Was a pilot/test intervention conducted?",
                "type" => "string"
            },
            "5.5" => {
                "name" => "Was external expertise or guidance consulted on how to best restore the site?",
                "type" => "string"
            },
            "6.1" => {
                "name" => "Which stakeholders undertook the project activities at the site?",
                "type" => "6.1 stakeholders"
            },
            "6.2" => {
                "name" => "What biophysical interventions were used to restore/rehabilitate the site?",
                "type" => "multiselect"
            },
            "6.2a" => {
                "name" => "What was the duration of the biophysical interventions?",
                "type" => "6.2a daterange"
            },
            "6.2b" => {
                "name" => "What mangrove species were used? What was the source of seeds/propagules or seedlings?",
                "type" => "6.2b species"
            },
            "6.2c" => {
                "name" => "Were mangrove-associated species planted?",
                "type" => "6.2c planted"
            },
            "6.3" => {
                "name" => "Did local participants receive restoration training?",
                "type" => "string"
            },
            "6.3a" => {
                "name" => "What type of organisations provided the restoration training?",
                "type" => "multiselect"
            },
            "6.4" => {
                "name" => "Were there other activities implemented to address the causes of decline at the site?",
                "type" => "multiselect"
            },
            "7.1" => {
                "name" => "What type of support was provided for the project activities conducted at the site?",
                "type" => "multiselect"
            },
            "7.2" => {
                "name" => "What is the main finance mechanism used to fund the project interventions at the site?",
                "type" => "TODO"
            },
            "7.3" => {
                "name" => "What funders provided monetary support?",
                "type" => "TODO"
            },
            "7.4" => {
                "name" => "What was the total cost of the project activities at the site?",
                "type" => "TODO"
            },
            "7.5" => {
                "name" => "What was the breakdown of the costs of the project activities?",
                "type" => "TODO"
            },
            "7.5a" => {
                "name" => "What was the approximate percentage split in expenditure between the different biophysical interventions and/or community activities?",
                "type" => "TODO"
            },
            "7.6" => {
                "name" => "What non-monetised contributions were made to the project activities at the site?",
                "type" => "multiselect"
            },
            "8.1" => {
                "name" => "What date was this management status and effectiveness assessment conducted?",
                "type" => "date"
            },
            "8.2" => {
                "name" => "Which stakeholders currently manage the site?",
                "type" => "TODO"
            },
            "8.3" => {
                "name" => "Are these stakeholders involved in the project activities able to influence management rules at the site?",
                "type" => "string"
            },
            "8.4" => {
                "name" => "Has any aspect of the management status of the site changed since the start of the project activities?",
                "type" => "string"
            },
            "8.4a" => {
                "name" => "What is the current management status of the site?",
                "type" => "string"
            },
            "8.4b" => {
                "name" => "Are management activities at the site recognized in statutory or customary laws?",
                "type" => "string"
            },
            "8.4c" => {
                "name" => "Name of the formal management area the site is contained within (if relevant)?",
                "type" => "string"
            },
            "8.5" => {
                "name" => "Has the protected status of the site changed since the start of the project activities?",
                "type" => "string"
            },
            "8.6" => {
                "name" => "What is the main finance mechanism used to fund ongoing site management?",
                "type" => "string"
            },
            "8.7" => {
                "name" => "Is the current budget or funds used to support on-going management activities at the site sufficient?",
                "type" => "string"
            },
            "8.7" => {
                "name" => "Is the current budget or funds used to support on-going management activities at the site sufficient?",
                "type" => "string"
            },
            "8.8" => {
                "name" => "Do those responsible for on-going management at the site (e.g., staff, community associations, management groups) have sufficient capacity and resources to enforce the rules and regulations?"
                "type" => "string"
            },
            "8.9" => {
                "name" => "Is there an effective strategy or approach for ensuring benefits from the site are shared equitably among local stakeholders?"
                "type" => "string"
            },
            "8.10" => {
                "name" => "Is the site consciously managed to adapt to climate change?"
                "type" => "string"
            },
        }

        return pdf_report_formatter
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
        return site.id, registration_intervention_answers, monitoring_answers
    end

    def report_params
        params.except(:format, :site).permit(:site_id)
    end

    def export_pdf_single_site
        site = Site.find(params[:site_id])

        @single_site = []
        @answer_array = []
        site_row = {}
        @site_dictionary = Hash.new { |h, k| h[k] = h.dup.clear }
        site_id, registration_intervention_answers, monitoring_answers = get_answers_by_site(site.id)
        # answers = monitoring_answers.uuid
        pdf_format = pdf_report_formatter
        # puts pdf_format

        registration_intervention_answers.each { |answer|
            if answer.answer_value.present?
                answer.question_id
                
                # TODO False in a boolean seems to not display the item
                if pdf_format.key?(answer.question_id)
                    @site_dictionary[answer.question_id][:value] = answer.answer_value
                    @site_dictionary[answer.question_id][:name] = pdf_format[answer.question_id]["name"]
                    case pdf_format[answer.question_id]["type"]
                    when "string"
                        @site_dictionary[answer.question_id][:value] = answer.answer_value.to_s
                    when "list"
                        @site_dictionary[answer.question_id][:value] = answer.answer_value.to_s
                    when "date"
                        @site_dictionary[answer.question_id][:value] = DateTime.parse(@site_dictionary[answer.question_id.to_s][:value]).to_date.to_s
                    when "boolean"
                        if @site_dictionary[answer.question_id][:value]
                            @site_dictionary[answer.question_id][:value] = "Yes"
                        else
                            @site_dictionary[answer.question_id][:value] = "No"
                        end
                    when "multiselect"
                        select_array = []
                        @site_dictionary[answer.question_id][:value]["selectedValues"].each { |x|
                            select_array.push(x)
                        }
                        if @site_dictionary[answer.question_id][:value]["isOtherChecked"]
                            select_array.push("Other: " + @site_dictionary[answer.question_id][:value]["otherValue"])
                        end
                        @site_dictionary[answer.question_id][:value] = select_array
                    when "1.2 countries"
                        country_array = []
                        @site_dictionary[answer.question_id][:value].each { |x|
                            country_array.push(x["properties"]["country"])
                        }
                        @site_dictionary[answer.question_id][:value] = country_array
                    when "2.1 stakeholders"
                        stakeholder_array = []
                        @site_dictionary[answer.question_id][:value].each { |x|
                            stakeholder_name = x["stakeholderName"]
                            stakeholder_type = x["stakeholderType"]
                            stakeholder_array.push("Name: " + stakeholder_name + ", Type: " + stakeholder_type)
                        }
                        @site_dictionary[answer.question_id][:value] = stakeholder_array
                    when "5.3f species"
                        species_array = []
                        @site_dictionary[answer.question_id][:value].each { |x|
                            species_type = x["mangroveSpeciesType"]
                            percentage = x["percentageComposition"]
                            species_array.push("Species: " + species_type + ", Percent: " + percentage.to_s)
                        }
                        @site_dictionary[answer.question_id][:value] = species_array
                    when "5.3g measurements"
                        measurements_array = []
                        @site_dictionary[answer.question_id][:value].each { |x|
                            if x["measurementValue"].present?
                                measurement_type = x["measurementType"]
                                measurement_value = x["measurementValue"]
                            measurements_array.push("Type: " + measurement_type + ", Value: " + measurement_value)
                            end
                        }
                        @site_dictionary[answer.question_id][:value] = measurements_array
                    when "6.1 stakeholders"
                        stakeholder_array = []
                        @site_dictionary[answer.question_id][:value].each { |x|
                            stakeholder = x["stakeholder"]
                            stakeholder_type = x["stakeholderType"]
                            stakeholder_array.push("Name: " + stakeholder + ", Type: " + stakeholder_type)
                        }
                        @site_dictionary[answer.question_id][:value] = stakeholder_array
                    # TODO - needs testing
                    when "6.2a daterange"
                        date_array = []
                        if @site_dictionary[answer.question_id][:value]["startDate"].present?
                            start_date = DateTime.parse(x["startDate"]).to_date.to_s
                            date_array.push("Start Date: " + start_date)
                        end
                        if @site_dictionary[answer.question_id][:value]["endDate"].present?
                            end_date = DateTime.parse(x["endDate"]).to_date.to_s
                            date_array.push("End Date: " + end_date)
                        end
                        @site_dictionary[answer.question_id][:value] = date_array
                    when "6.2b species"
                        species_array = []
                        @site_dictionary[answer.question_id][:value].each { |x|
                            type = x["type"]
                            species_array.push(type)
                            if x["seed"]["checked"]
                                seed_source = x["seed"]["source"][0]
                                seed_count = x["seed"]["count"]
                                species_array.push(seed_source, seed_count)
                            end
                            if x["propagule"]["checked"]
                                propagule_source = x["propagule"]["source"][0]
                                propagule_count = x["propagule"]["count"]
                                species_array.push(propagule_source, propagule_count)
                            end
                        }
                        @site_dictionary[answer.question_id][:value] = species_array
                    when "6.2c planted"
                        planted_array = []
                        @site_dictionary[answer.question_id][:value].each { |x|
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
                        @site_dictionary[answer.question_id][:value] = planted_array
                    else
                        @site_dictionary[answer.question_id][:value] = "TODO"
                    end
                
                else
                    
                end
            end
        }


        @site_dictionary = @site_dictionary.sort

        site_row["site_id"] = site.id
        site_row["site_name"] = site.site_name

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
        options = {
            :margin_top => '0.5in',
            :margin_right => '0.5in',
            :margin_bottom => '0.5in',
            :margin_left => '0.5in'
        }

        # Render the HTML (temporary solution)
        render(:template => 'v2/pdf_report/single_site', :formats => [:html])
    end

    def export_pdf
        @all_site_rows = []
        Site.all.each { |site|
            site_row = {}
            site_id, registration_intervention_answers, monitoring_answers = get_answers_by_site(site.id)

            puts site

            site_row["site_id"] = site.id
            site_row["site_name"] = site.site_name

            # registration_intervention_answers.each { |answer|
            #     site_row[answer.question_id] = answer.answer_value
            # }

            # generate Mapbox url
            # site_row["site_map"] = generate_mapbox_url(site_row["1.3"])

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
        # pdf_file = PDFKit.new(html, options).to_file("#{Rails.root}/tmp/sites.pdf")
        kit = PDFKit.new(html, :page_size => 'Letter')
        pdf = kit.to_pdf
        # file = kit.to_file("#{Rails.root}/tmp/sites.pdf")

        # Send the generated PDF file as a download
        # send_file file.path, :type => 'application/pdf', :disposition => 'attachment', :filename => 'sites.pdf'
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