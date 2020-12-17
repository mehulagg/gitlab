# frozen_string_literal: true

module EE
  module Todos
    module Destroy
      module EntityLeaveService
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :remove_confidential_resource_todos
        def remove_confidential_resource_todos
          super

          return unless entity.is_a?(Namespace)

          ::Todo
            .for_target(confidential_epics.select(:id))
            .for_type(::Epic.name)
            .for_user(user)
            .delete_all
        end

        private

        def confidential_epics
          ::Epic
            .in_selected_groups(non_authorized_reporter_groups)
            .confidential
        end
      end
    end
  end
end
