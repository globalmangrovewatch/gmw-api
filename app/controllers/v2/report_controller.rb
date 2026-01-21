class V2::ReportController < MrttApiController
  skip_before_action :authenticate_user!, only: [:answers_as_xlsx, :answers, :answers_by_site]
  before_action :authenticate_user_unless_public_only, only: [:answers_as_xlsx]
  before_action :try_authenticate_user, only: [:answers, :answers_by_site]

  def answers_by_site
    site_id = report_params[:site_id]
    @site_id, @registration_intervention_answers, @monitoring_answers = get_answers_by_site(site_id, false)
  end

  def answers
    @answers = []
    Site.all.each { |site|
      site_id, registration_intervention_answers, monitoring_answers = get_answers_by_site(site.id, false)
      @answers.push({
        "site_id" => site_id,
        "registration_intervention_answers" => registration_intervention_answers,
        "monitoring_answers" => monitoring_answers
      })
    }
  end

  def get_answers_by_site(site_id, public_only = true)
    site = Site.find(site_id)
    landscape = site.landscape
    organization_ids = landscape.organization_ids
    registration_intervention_answers = site.registration_intervention_answers

    # Non-admin and non-members are allowed to view answers on public section of the form
    # Instead of returning: insufficient_privilege && return
    # We restrict the sections instead
    @restricted_sections = []
    is_privileged = current_user && (current_user.is_admin || current_user.is_member_of_any(organization_ids))
    if !is_privileged || public_only
      @restricted_sections = (
          if site.section_data_visibility
            site.section_data_visibility.map { |key, value| (value == "private") ? key : nil }.select { |i| !i.nil? }
          else
            []
          end
        )
    end

    monitoring_events = {}
    site.monitoring_answers.each { |answer|
      if !monitoring_events.key?(answer.uuid)
        monitoring_events[answer.uuid] = {
          "uuid" => answer.uuid,
          "form_type" => answer.form_type,
          "monitoring_date" => answer.monitoring_date,
          "answers" => {}
        }
      end
      if !@restricted_sections.include?(answer.question_id.split(".")[0])
        monitoring_events[answer.uuid]["answers"][answer.question_id] = answer.answer_value
      end
    }

    monitoring_answers = []
    monitoring_events.each { |key, value|
      monitoring_answers.push(value)
    }
    [site.id, registration_intervention_answers.select { |answer| !@restricted_sections.include?(answer.question_id.split(".")[0]) }, monitoring_answers]
  end

  def get_question_names
    pdf_controller = V2::PdfReportController.new
    pdf_controller.pdf_report_formatter
  end

  def answers_as_xlsx
    # query parameters
    site_id = report_params[:site_id]
    organization_id = report_params[:organization_id]
    public_only = ActiveModel::Type::Boolean.new.cast(report_params[:public_only])

    if public_only.nil?
      public_only = true
    end

    # prep
    empty_answer = nil
    question_hash = get_question_names
    question_section_mappings = {
      registration: ["1.1a", "1.1b", "1.1c", "1.2", "1.3", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3.1", "3.2", "3.3", "4.1", "4.2", "5.1", "5.2", "5.2a", "5.2b", "5.2c", "5.3", "5.3a", "5.3b", "5.3c", "5.3d", "5.3e", "5.3f", "5.3g", "5.4", "5.5"],
      intervention: ["6.1", "6.2", "6.2a", "6.2b", "6.2c", "6.3", "6.3a", "6.4", "7.1", "7.2", "7.3", "7.4", "7.5", "7.5a", "7.6"],
      monitoring: ["8.1", "8.2", "8.3", "8.4", "8.4a", "8.4b", "8.4c", "8.5", "8.5a", "8.6", "8.7", "8.8", "8.9", "8.10", "9.1", "9.2", "9.2a", "9.3", "9.3a", "9.3b", "9.4", "9.5", "10.1", "10.2", "10.3", "10.3a", "10.4", "10.5", "10.6", "10.6a", "10.7", "10.8"]
    }
    question_key_ids = {
      registration: question_hash.select { |k, v| question_section_mappings[:registration].include? k }.map { |k, v| "#{k} - #{v["name"]}" },
      intervention: question_hash.select { |k, v| question_section_mappings[:intervention].include? k }.map { |k, v| "#{k} - #{v["name"]}" },
      monitoring: question_hash.select { |k, v| question_section_mappings[:monitoring].include? k }.map { |k, v| "#{k} - #{v["name"]}" }
    }

    columns = ["site_id", "site_name"]
    registration_sheet_columns = columns + question_key_ids[:registration]
    intervention_sheet_columns = columns + question_key_ids[:intervention]
    monitoring_sheet_columns = columns + question_key_ids[:monitoring]

    # initialize workbook
    p = Axlsx::Package.new
    wb = p.workbook

    # create styles
    style_header = wb.styles.add_style({alignment: {vertical: :center, horizontal: :center, wrap_text: true}, bg_color: "000000", fg_color: "FFFFFF"})
    style_row = wb.styles.add_style({alignment: {vertical: :top}})

    # create registration worksheet
    registration_worksheet = wb.add_worksheet(name: "Registration")
    intervention_worksheet = wb.add_worksheet(name: "Intervention")
    monitoring_worksheet = wb.add_worksheet(name: "Monitoring")

    # generate cells data
    all_sites_rows = []
    monitoring_sites_rows = []

    # filter by site_id, organization_id
    sites = if !organization_id.nil?
      Site.joins(landscape: :organizations).where(organizations: {id: organization_id})
    elsif !site_id.nil?
      Site.find([site_id])
    else
      Site.all
    end

    sites.each { |site|
      site_row = {}
      site_id, registration_intervention_answers, monitoring_answers = get_answers_by_site(site.id, public_only)

      site_row["site_id"] = site.id
      site_row["site_name"] = site.site_name

      registration_intervention_answers.each { |answer|
        # site_row[answer.question_id] = answer.answer_value
        site_row[answer.question_id] = to_human_readable(answer.question_id, answer.answer_value)
      }

      all_sites_rows.push(site_row)

      if !monitoring_answers.empty?
        monitoring_answers.each { |event|
          monitoring_site_row = {}
          monitoring_site_row["site_id"] = site.id
          monitoring_site_row["site_name"] = site.site_name

          eco_start_end_date = {}
          event["answers"].each do |question_id, answer|
            if ["10.1a", "10.1b"].include? question_id
              eco_start_end_date[question_id] = to_human_readable(question_id, answer)
              next
            end
            if ["10.1", "10.3a"].include? question_id
              next
            elsif ["10.4a"].include? question_id
              monitoring_site_row["10.3a"] = to_human_readable(question_id, answer)
            end
            monitoring_site_row[question_id] = to_human_readable(question_id, answer)
          end
          if eco_start_end_date.any?
            puts eco_start_end_date["10.1a"]
            puts eco_start_end_date["10.1b"]
            monitoring_site_row["10.1"] = "start date: #{eco_start_end_date["10.1a"]}\nend date: #{eco_start_end_date["10.1b"]}"
          end
          monitoring_sites_rows.push(monitoring_site_row)
        }
      end
    }

    # add registration header
    registration_worksheet.add_row registration_sheet_columns, style: style_header, types: :string

    # add registration rows
    all_sites_rows.each { |site_row|
      row = []
      registration_sheet_columns.each { |column|
        cell_value = site_row[column.split(" - ")[0]] || empty_answer
        row.push(cell_value)
      }
      registration_worksheet.add_row row, style: style_row
    }

    # add intervention header
    intervention_worksheet.add_row intervention_sheet_columns, style: style_header, types: :string

    # add intervention rows
    all_sites_rows.each { |site_row|
      row = []
      intervention_sheet_columns.each { |column|
        cell_value = site_row[column.split(" - ")[0]] || empty_answer
        row.push(cell_value)
      }
      intervention_worksheet.add_row row, style: style_row
    }

    # add monitoring header
    monitoring_worksheet.add_row monitoring_sheet_columns, style: style_header, types: :string

    # add monitoring rows
    monitoring_sites_rows.each { |site_row|
      row = []
      monitoring_sheet_columns.each { |column|
        cell_value = site_row[column.split(" - ")[0]] || empty_answer
        row.push(cell_value)
      }
      monitoring_worksheet.add_row row, style: style_row
    }

    # export
    filename = "sites_report_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.xlsx"
    send_data(p.to_stream.read, filename: filename, disposition: "attachment")
  end

  def report_params
    params.except(:format, :site).permit(:site_id, :organization_id, :public_only)
  end

  def authenticate_user_unless_public_only
    public_only = ActiveModel::Type::Boolean.new.cast(params[:public_only])
    public_only = true if public_only.nil?

    if public_only
      try_authenticate_user
    else
      authenticate_user!
    end
  end

  def try_authenticate_user
    authenticate_user_from_token!
  end

  def to_human_readable(question, answer)
    # get answers data types
    dtypes = Rails.application.config.data_types

    # handle null values
    if answer.nil?
      return ""
    end

    if dtypes[question] == "object"
      answer_obj_to_str(answer)
    elsif dtypes[question] == "array"
      answer.each { |i|
        if i.instance_of? String
          return answer.join("\n")
        elsif i.instance_of? Hash
          return answer.map { |obj| answer_obj_to_str(obj) }.join("\n\n")
        else
          return answer.to_json
        end
      }
    elsif dtypes[question] == "date"
      Date.parse(answer).strftime("%m/%d/%Y")
    elsif dtypes[question] == "int"
      answer.to_s
    elsif dtypes[question] == "str"
      ("Yes" if answer == true) || ("No" if answer == false) || answer.to_s
    elsif dtypes[question] == "geojson"
      # convert geojson to map image via Mapbox Static API
      geojson = answer["features"][0]
      # feature = RGeo::GeoJSON.decode(geojson)
      geojson = reduce_precision_geojson(geojson)
      geojson.to_json
    else
      answer.to_json
    end
  end

  def answer_obj_to_str(answer)
    answer.map { |k, v| "#{k}: #{v}" }.join("\n")
  end

  def reduce_precision_geojson(geojson)
    geometry = geojson["geometry"]
    coordinates = geometry["coordinates"]
    coordinates_o = coordinates[0]
    coordinates_o.each { |coord|
      coord[0] = coord[0].truncate(2)
      coord[1] = coord[1].truncate(2)
    }
    geojson
  end
end
