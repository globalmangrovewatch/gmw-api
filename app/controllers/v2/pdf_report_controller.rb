class V2::PdfReportController < MrttApiController
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

    def export_pdf
        @all_site_rows = []
        Site.all.each { |site|
            site_row = {}
            site_id, registration_intervention_answers, monitoring_answers = get_answers_by_site(site.id)

            site_row["site_id"] = site.id
            site_row["site_name"] = site.site_name

            registration_intervention_answers.each { |answer|
                site_row[answer.question_id] = answer.answer_value
            }

            # generate Mapbox url
            site_row["site_map"] = generate_mapbox_url(site_row["1.3"])
            
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

        # Create a new PDFKit object and convert the HTML to a PDF file
        pdf_file = PDFKit.new(html, options).to_file("#{Rails.root}/tmp/sites.pdf")

        # Send the generated PDF file as a download
        send_file pdf_file.path, :type => 'application/pdf', :disposition => 'attachment', :filename => 'sites.pdf'

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