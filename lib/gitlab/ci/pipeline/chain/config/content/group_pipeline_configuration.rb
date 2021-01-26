# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module Config
          class Content
            class GroupPipelineConfiguration < Source
              def content
                strong_memoize(:content) do
                  next unless pipeline_configuration_full_path

                  YAML.dump('include' => [{ 'local' => pipeline_configuration_full_path }])
                end
              end

              def source
                :parameter_source
              end

              private

              def pipeline_configuration_full_path
                return unless project
                return unless project&.compliance_framework_setting&.compliance_management_framework

                project.compliance_framework_setting.compliance_management_framework.pipeline_configuration_full_path
              end
            end
          end
        end
      end
    end
  end
end
