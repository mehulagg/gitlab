# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Variables
        class Builder
          module Project
            extend ::Gitlab::Utils::Override

            override :fabricate
            def fabricate
              super.concat(requirements_ci_variables)
            end

            private

            def requirements_ci_variables
              ::Gitlab::Ci::Variables::Collection.new.tap do |variables|
                if @project.requirements.opened.any?
                  variables.append(key: 'CI_HAS_OPEN_REQUIREMENTS', value: 'true')
                end
              end
            end
          end
        end
      end
    end
  end
end
