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

                  path_file, path_project = pipeline_configuration_full_path.split('@', 2)
                  YAML.dump('include' => [{ 'project' => path_project, 'file' => path_file }, { 'local' => ci_config_path }])
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
