# frozen_string_literal: true

module EE
  module Banzai
    module Filter
      module References
        module ReferenceCache
          extend ::Gitlab::Utils::Override

          override :current_project_namespace_path
          def current_project_namespace_path
            strong_memoize(:current_project_namespace_path) do
              (project&.namespace || group)&.full_path
            end
          end
        end
      end
    end
  end
end
