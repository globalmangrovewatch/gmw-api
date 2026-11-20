require "rails_helper"

RSpec.describe OrganizationLogo, type: :model do
  def upload(bytes, filename: "logo.bin", content_type: "application/octet-stream")
    file = Tempfile.new(["logo", File.extname(filename)])
    file.binmode
    file.write(bytes)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, content_type)
  end

  def png_bytes
    Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")
  end

  def jpeg_bytes
    "\xFF\xD8\xFF\xD9".b
  end

  def webp_bytes
    Base64.decode64("UklGRiQAAABXRUJQVlA4IBgAAAAwAQCdASoBAAEAAwA0JaQAA3AA/vuUAAA=")
  end

  it "accepts PNG, JPEG, and WebP up to 2 MB and stores the detected type" do
    png = described_class.prepare(upload(png_bytes))
    jpeg = described_class.prepare(upload(jpeg_bytes, content_type: "image/png"))
    webp = described_class.prepare(upload(webp_bytes, content_type: "text/plain"))

    expect(png).to be_ok
    expect(png.attachable[:content_type]).to eq("image/png")
    expect(png.attachable[:filename]).to eq("logo.png")
    expect(jpeg.attachable[:content_type]).to eq("image/jpeg")
    expect(webp.attachable[:content_type]).to eq("image/webp")

    limit = ("\x89PNG\r\n\x1A\n".b + ("a".b * (OrganizationLogo::MAX_BYTES - 8)))
    expect(described_class.prepare(upload(limit))).to be_ok
  end

  it "rejects a blank file, an unknown type, and a file over 2 MB" do
    expect(described_class.prepare(nil).error).to eq("can't be blank")
    expect(described_class.prepare(upload("not-an-image")).error).to eq("must be a PNG, JPEG, WebP, or SVG")
    expect(described_class.prepare(upload("a" * (OrganizationLogo::MAX_BYTES + 1))).error).to eq("must be 2 MB or smaller")
  end

  it "stores a sanitized SVG and drops active content" do
    source = <<~SVG
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
      <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10">
        <script>alert(1)</script>
        <foreignObject><body xmlns="http://www.w3.org/1999/xhtml"><iframe></iframe></body></foreignObject>
        <rect id="mark" width="10" height="10" fill="url(#grad)" onclick="alert(1)" style="fill:url(https://evil.test/x)"/>
        <a href="javascript:alert(1)"><text>x</text></a>
        <image href="https://evil.test/pixel.png"/>
        <use href="#mark"/>
      </svg>
    SVG

    prepared = described_class.prepare(upload(source, filename: "mark.svg", content_type: "image/svg+xml"))

    expect(prepared).to be_ok
    stored = prepared.attachable[:io].read
    expect(prepared.attachable[:content_type]).to eq("image/svg+xml")
    expect(stored).to include("mark")
    expect(stored).to include("#grad")
    expect(stored).not_to include("<script")
    expect(stored).not_to include("onclick")
    expect(stored).not_to include("javascript:")
    expect(stored).not_to include("foreignObject")
    expect(stored).not_to include("evil.test")
    expect(stored).not_to include("<image")
    expect(stored).to include('href="#mark"')
  end

  it "rejects SVG that is not well formed or is another XML document" do
    html = "<?xml version=\"1.0\"?><html xmlns=\"http://www.w3.org/1999/xhtml\"><svg></svg></html>"
    entity = <<~SVG
      <?xml version="1.0"?>
      <!DOCTYPE svg [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
      <svg xmlns="http://www.w3.org/2000/svg">&xxe;</svg>
    SVG

    expect(described_class.prepare(upload("<svg><rect")).error).to eq("must be a valid SVG")
    expect(described_class.prepare(upload(html)).error).to eq("must be a valid SVG")
    expect(described_class.prepare(upload(entity)).error).to eq("must be a valid SVG")
  end

  it "serves sanitized SVG and WebP inline" do
    expect(ActiveStorage.content_types_allowed_inline).to include("image/webp", "image/svg+xml")
    expect(ActiveStorage.content_types_to_serve_as_binary).not_to include("image/svg+xml")
  end

  it "keeps production and staging logos in Postgres and serves them from the app" do
    production = Rails.root.join("config/environments/production.rb").read
    staging = Rails.root.join("config/environments/staging.rb").read
    storage = Rails.root.join("config/storage.yml").read
    gemfile = Rails.root.join("Gemfile").read

    expect(production).to include("config.active_storage.service = :database")
    expect(production).to include("config.active_storage.resolve_model_to_route = :rails_storage_proxy")
    expect(staging).to include('require_relative "production"')
    expect(storage).to include("service: Database")
    expect(storage).not_to include("AWS_")
    expect(storage).not_to include("service: S3")
    expect(gemfile).not_to include("aws-sdk")

    service = ActiveStorage::Service.configure(:database, {database: {service: "Database"}})
    payload = png_bytes
    checksum = Digest::MD5.base64digest(payload)
    service.upload("logo-key", StringIO.new(payload), checksum: checksum)

    expect(service.download("logo-key")).to eq(payload)
    expect(service.download_chunk("logo-key", 0..2)).to eq(payload.byteslice(0..2))
    expect(ActiveStorage::Service::DatabaseService::FileRecord.find_by!(key: "logo-key").data).to eq(payload)

    service.delete("logo-key")
    expect(service.exist?("logo-key")).to be(false)
  end
end
