# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module EnabledNamespaces
      class CreateService
        include CommonMethods

        def initialize(enabled_namespace: Analytics::DevopsAdoption::EnabledNamespace.new, params: {}, current_user:)
          @enabled_namespace = enabled_namespace
          @params = params
          @current_user = current_user
        end

        def execute
          authorize!

          enabled_namespace.assign_attributes(namespace: namespace, display_namespace: display_namespace)

          if enabled_namespace.save
            Analytics::DevopsAdoption::CreateSnapshotWorker.perform_async(enabled_namespace.id)

            ServiceResponse.success(payload: response_payload)
          else
            ServiceResponse.error(message: 'Validation error', payload: response_payload)
          end
        end

        private

        attr_reader :enabled_namespace

        def response_payload
          { enabled_namespace: enabled_namespace }
        end
      end
    end
  end
end
