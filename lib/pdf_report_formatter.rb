module PDFReportFormatter
    def pdf_report_formatter
        pdf_report_formatter = {
            "1.1a" => { 
                "name" => "Project start date",
                "type" => "date"
                },
            "1.1b" => {
                "name" => "Does this project have an end date?",
                "type" => "boolean"
            }
            
        }
        return pdf_report_formatter
    end
    module_function :pdf_report_formatter
end