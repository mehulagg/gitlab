# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module EnabledNamespaces
      class DeleteService
        include CommonMethods

        def initialize(enabled_namespace:, current_user:)
          @enabled_namespace = enabled_namespace
          @current_user = current_user
        end

        def execute
          authorize!

          begin
            enabled_namespace.destroy!

            ServiceResponse.success(payload: response_payload)
          rescue ActiveRecord::RecordNotDestroyed
            ServiceResponse.error(message: 'DevOps Adoption EnabledNamespace deletion error', payload: response_payload)
          end
        end

        private

        attr_reader :enabled_namespace

        delegate :namespace, :display_namespace, to: :enabled_namespace

        def response_payload
          { enabled_namespace: enabled_namespace }
        end
      end
    end
  end
end
