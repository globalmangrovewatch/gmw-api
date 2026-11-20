inline_types = Rails.application.config.active_storage.content_types_allowed_inline
%w[image/webp image/svg+xml].each do |content_type|
  inline_types << content_type unless inline_types.include?(content_type)
end

Rails.application.config.active_storage.content_types_to_serve_as_binary.delete("image/svg+xml")
