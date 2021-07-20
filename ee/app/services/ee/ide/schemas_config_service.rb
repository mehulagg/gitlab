# frozen_string_literal: true

module EE
  module Ide
    module SchemasConfigService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        result = super
        return result if result[:status] == :success && !result[:schema].empty?

        check_access_and_load_config!
        success(schema: schema_from_config_for(params[:filename]) || {})
      rescue StandardError => e
        error(e.message)
      end

      private

      def schema_from_config_for(filename)
        return {} unless project.feature_available?(:ide_schema_config)

        find_schema(filename, config.schemas_value || [])
      end
    end
  end
end
