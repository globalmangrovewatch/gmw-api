class V2::ReportController < MrttApiController
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

    def answers_as_xlsx
        # prep
        empty_answer = "---"
        registration_sheet_columns = ["site_id", "site_name", "1.1a", "1.1b", "1.1c", "1.2", "1.3", "2.2", "2.3", "5.3f"]

        # initialize workbook
        p = Axlsx::Package.new
        wb = p.workbook

        # create styles
        style_header = wb.styles.add_style({:alignment => {:vertical => :center, :horizontal => :center, :wrap_text => true}, :bg_color => "000000", :fg_color => "FFFFFF"})    
        style_row = wb.styles.add_style({:alignment => {:vertical => :top}})    

        # create registration worksheet
        registration_worksheet = wb.add_worksheet(name: "Registration")

        # generate cells data
        all_site_rows = []
        Site.all.each { |site|
            site_row = {}
            site_id, registration_intervention_answers, monitoring_answers = get_answers_by_site(site.id)

            site_row["site_id"] = site.id
            site_row["site_name"] = site.site_name

            registration_intervention_answers.each { |answer|
                # site_row[answer.question_id] = answer.answer_value
                site_row[answer.question_id] = to_human_readable(answer.question_id, answer.answer_value)
            }
            
            all_site_rows.push(site_row)
        }

        # add header
        registration_worksheet.add_row registration_sheet_columns, :style => style_header

        # add rows
        all_site_rows.each { |site_row|
            row = []
            registration_sheet_columns.each { |column|
                cell_value = site_row[column] || empty_answer
                row.push(cell_value)
            }
            registration_worksheet.add_row row, :style => style_row
        }
    
        # export
        filename = "sites_report_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.xlsx"
        send_data(p.to_stream.read, filename: filename, disposition: 'attachment')
    end

    def report_params
        params.except(:format, :site).permit(:site_id)
    end

    def to_human_readable(question, answer)
        if question == "5.3f"
            return answer.map { |i|
                "%s: %s" % [i["mangroveSpeciesType"], i["percentageComposition"]]
            }.join("\n")
        elsif ["1.1a", "1.1c"].include? question
            return Date.parse(answer).strftime("%m/%d/%Y")
        elsif ["1.1b"].include? question
            return ("Yes" if answer == true) || ("No" if answer == false) || answer.to_json
        elsif ["1.2"].include? question
            return answer[0]["properties"]["country"]
        elsif question == "1.3"
            # convert geojson to map image via Mapbox Static API
            geojson = answer["features"][0]
            feature = RGeo::GeoJSON.decode(geojson)            
            geojson = reduce_precision_geojson(geojson)
            url = "https://api.mapbox.com/v4/mapbox.satellite/geojson(%s)/%s/600x300@2x.png?access_token=%s" % [geojson.to_json, "auto", "MAPBOX_ACCESS_TOKEN"]
            return url
        else
            return answer.to_json
        end
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