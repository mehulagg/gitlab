# frozen_string_literal: true

module EE
  module API
    module Validations
      module Validators
        module CheckAssigneesCount
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          private

          override :param_allowed?
          def param_allowed?(attr_name, params)
            super || License.feature_available?(:multiple_issue_assignees)
          end
        end
      end
    end
  end
end
