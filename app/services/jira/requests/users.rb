# frozen_string_literal: true

module Jira
  module Requests
    class Users < Base
      extend ::Gitlab::Utils::Override

      def initialize(jira_service, params = {})
        super(jira_service, params)

        @query = params[:query]
      end

      private

      attr_reader :query

      override :url
      def url
        "#{base_api_url}/user/assignable/multiProjectSearch?projectKeys=#{jira_service.project_key}"
      end

      override :build_service_response
      def build_service_response(response)
        response
      end
    end
  end
end
