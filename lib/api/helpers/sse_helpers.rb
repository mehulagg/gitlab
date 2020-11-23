# frozen_string_literal: true

module API
  module Helpers
    module SSEHelpers
      def request_from_sse?(project)
        uri = URI.parse(request.referer)
        uri.path.sub(::Gitlab::Routing.url_helpers.project_path(project), '').starts_with?('/-/sse/')
      rescue URI::InvalidURIError
        false
      end
    end
  end
end
