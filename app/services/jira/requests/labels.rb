# frozen_string_literal: true

module Jira
  module Requests
    class Labels < Base
      extend ::Gitlab::Utils::Override

      def initialize(jira_service, params = {})
        super(jira_service, params)

        @query = params[:query]
      end

      private

      attr_reader :query

      override :url
      def url
        # This is only available on Jira Cloud
        "#{base_api_url}/label"
      end

      override :build_service_response
      def build_service_response(response)
        response
      end
    end
  end
end
