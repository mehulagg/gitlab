# frozen_string_literal: true

module Types
  module Projects
    class ServiceTypeEnum < BaseEnum
      graphql_name 'ServiceType'

      ::Integration.available_services_types(include_dev: false).each do |type|
        replacement = Integration.integration_type_for_service_type(type)

        if replacement.present?
          deprecation = {
            reason: :renamed,
            replacement: "ServiceType.#{replacement.underscore.upcase}",
            milestone: '14.0'
          }
        end

        value type.underscore.upcase,
              value: replacement.presence || type,
              description: "#{type} type",
              deprecated: deprecation
      end

      ::Integration.available_integration_types(include_dev: false).each do |type|
        value type.underscore.upcase, value: type, description: "Integration with #{type.chomp('Integration')}"
      end
    end
  end
end
