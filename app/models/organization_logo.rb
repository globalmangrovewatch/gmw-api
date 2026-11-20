class OrganizationLogo
  MAX_BYTES = 2.megabytes
  SVG_NAMESPACE = "http://www.w3.org/2000/svg"

  CONTENT_TYPES = {
    png: "image/png",
    jpeg: "image/jpeg",
    webp: "image/webp",
    svg: "image/svg+xml"
  }.freeze

  EXTENSIONS = {
    png: "png",
    jpeg: "jpg",
    webp: "webp",
    svg: "svg"
  }.freeze

  DISALLOWED_ELEMENTS = %w[
    script foreignobject iframe embed object audio video
    handler set animate animatetransform animatemotion
    image feimage style
  ].freeze

  REFERENCE_ATTRIBUTES = %w[href src poster action formaction].freeze

  Prepared = Struct.new(:error, :attachable, keyword_init: true) do
    def ok?
      error.nil?
    end
  end

  def self.prepare(upload)
    new(upload).prepare
  end

  def initialize(upload)
    @upload = upload
  end

  def prepare
    return Prepared.new(error: "can't be blank") if @upload.blank?

    bytes = read_bytes
    return Prepared.new(error: "must be 2 MB or smaller") if bytes.bytesize > MAX_BYTES

    kind = detect(bytes)
    return Prepared.new(error: "must be a PNG, JPEG, WebP, or SVG") unless kind

    payload = (kind == :svg) ? sanitize_svg(bytes) : bytes
    return Prepared.new(error: "must be a valid SVG") if kind == :svg && payload.blank?
    return Prepared.new(error: "must be 2 MB or smaller") if payload.bytesize > MAX_BYTES

    Prepared.new(attachable: {
      io: StringIO.new(payload),
      filename: "logo.#{EXTENSIONS.fetch(kind)}",
      content_type: CONTENT_TYPES.fetch(kind),
      identify: false
    })
  end

  private

  def read_bytes
    if @upload.respond_to?(:tempfile)
      @upload.tempfile.rewind
      @upload.tempfile.read.b
    elsif @upload.respond_to?(:read)
      @upload.rewind if @upload.respond_to?(:rewind)
      @upload.read.to_s.b
    else
      @upload.to_s.b
    end
  end

  def detect(bytes)
    return :png if bytes.start_with?("\x89PNG\r\n\x1A\n".b)
    return :jpeg if bytes.start_with?("\xFF\xD8\xFF".b)
    return :webp if bytes.bytesize >= 12 && bytes.start_with?("RIFF".b) && bytes.byteslice(8, 4) == "WEBP".b
    return :svg if svg_markup?(bytes)

    nil
  end

  def svg_markup?(bytes)
    text = bytes.dup.force_encoding(Encoding::UTF_8)
    return false unless text.valid_encoding?

    stripped = text.delete_prefix("\uFEFF").lstrip
    stripped.match?(/\A<\?xml/i) || stripped.match?(/\A<svg[\s>\/]/i)
  end

  def sanitize_svg(bytes)
    source = bytes.dup.force_encoding(Encoding::UTF_8)
    return unless source.valid_encoding?
    return if source.match?(/<!ENTITY/i)

    source = source.delete_prefix("\uFEFF")
    source = source.sub(/<!DOCTYPE[^>]*>/i, "")
    document = Nokogiri::XML(source) { |config| config.strict.nonet }
    return unless svg_element?(document.root)

    document.xpath("//processing-instruction() | //comment()").each(&:remove)
    document.xpath("//*").each do |node|
      next unless node.element?

      if DISALLOWED_ELEMENTS.include?(node.name.downcase)
        node.remove
        next
      end

      node.attribute_nodes.each do |attribute|
        attribute.remove if unsafe_attribute?(attribute)
      end
    end
    return unless svg_element?(document.root)

    sanitized = document.to_xml
    return if sanitized.match?(/<\s*script|javascript\s*:|vbscript\s*:/i)

    sanitized
  rescue Nokogiri::XML::SyntaxError
    nil
  end

  def svg_element?(node)
    return false unless node&.element?
    return false unless node.name.casecmp("svg").zero?

    namespace = node.namespace
    namespace.nil? || namespace.href == SVG_NAMESPACE
  end

  def unsafe_attribute?(attribute)
    name = attribute.name.to_s.downcase
    value = attribute.value.to_s
    compact = value.gsub(/[\u0000-\u0020]+/, "")
    return true if name.start_with?("on")
    return true if compact.match?(/javascript:|vbscript:|data:/i)
    return true if unsafe_url?(value)
    return true if name == "style" && value.match?(/expression\s*\(|@import|-moz-binding|behavior\s*:/i)
    return true if REFERENCE_ATTRIBUTES.include?(name) && !safe_reference?(value)

    false
  end

  def unsafe_url?(value)
    value.scan(/url\s*\(\s*([^)]*)\)/i).any? do |(inner)|
      reference = inner.strip.gsub(/\A['"]|['"]\z/, "").gsub(/[\u0000-\u0020]+/, "")
      !reference.match?(/\A#[A-Za-z_][\w:.-]*\z/)
    end
  end

  def safe_reference?(value)
    value.to_s.gsub(/[\u0000-\u0020]+/, "").match?(/\A#[A-Za-z_][\w:.-]*\z/)
  end
end
