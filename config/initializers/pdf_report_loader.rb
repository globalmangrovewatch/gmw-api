# require "pdf_report_formatter"
# include PDFReportFormatter
# Rails.application.configure do |config|
#     config.pdf_format = PDFReportFormatter.pdf_report_formatter
# end

PDFKit.configure do |config|
    config.default_options = {
      footer_right: "[page]"
    }
  end