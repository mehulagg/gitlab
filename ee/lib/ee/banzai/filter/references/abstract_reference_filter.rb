# frozen_string_literal: true

module EE
  module Banzai
    module Filter
      module References
        module AbstractReferenceFilter
          extend ::Gitlab::Utils::Override

          override :current_project_namespace_path
          def current_project_namespace_path
            @current_project_namespace_path ||= (project&.namespace || group)&.full_path
          end
        end
      end
    end
  end
end
