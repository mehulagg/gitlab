# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Config
        module Entry
          module Needs
            extend ActiveSupport::Concern

            NEEDS_CROSS_PROJECT_DEPENDENCIES_LIMIT = 5

            prepended do
              validations do
                validate on: :composed do
                  cross_dependencies = value[:cross_dependency].to_a
                  cross_project_dependencies = cross_dependencies.select { |dep| dep[:project] }

                  if cross_project_dependencies.size > NEEDS_CROSS_PROJECT_DEPENDENCIES_LIMIT
                    errors.add(:config, "must be less than or equal to #{NEEDS_CROSS_PROJECT_DEPENDENCIES_LIMIT}")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
