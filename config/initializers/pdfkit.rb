PDFKit.configure do |config|
  config.wkhtmltopdf = if File.exist?('/app/bin/wkhtmltopdf')
    '/app/bin/wkhtmltopdf'
  elsif File.exist?('/usr/local/bin/wkhtmltopdf')
    '/usr/local/bin/wkhtmltopdf'
  elsif File.exist?('/usr/bin/wkhtmltopdf')
    '/usr/bin/wkhtmltopdf'
  else
    `which wkhtmltopdf`.to_s.strip
  end
end

