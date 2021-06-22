# frozen_string_literal: true

module EE
  module Ci
    module PipelineEditorHelper
      extend ::Gitlab::Utils::Override

      override :js_pipeline_editor_data
      def js_pipeline_editor_data(project)
        return super unless project.licensed_feature_available?(:api_fuzzing)

        super.merge(
          "api-fuzzing-configuration-path" => project_security_configuration_api_fuzzing_path(project),
          "dast-configuration-path" => project_security_configuration_dast_path(project)
        )
      end
    end
  end
end
