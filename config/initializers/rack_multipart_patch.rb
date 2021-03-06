# frozen_string_literal: true

return unless Gitlab::Utils.to_boolean(ENV['ENABLE_RACK_MULTIPART_LOGGING'], default: true) && Gitlab.com?

module Rack
  module Multipart
    class << self
      module MultipartPatch
        def extract_multipart(req, params = Rack::Utils.default_query_parser)
          content_length = req.content_length.to_i
          log_multipart_warning(req, content_length) if content_length > 500_000_000

          super
        end

        def log_multipart_warning(req, content_length)
          message = {
            message: "Large multipart body detected",
            path: req.path,
            content_length: content_length,
            correlation_id: ::Labkit::Context.correlation_id
          }

          warn message.to_json
        end
      end

      prepend MultipartPatch
    end
  end
end
