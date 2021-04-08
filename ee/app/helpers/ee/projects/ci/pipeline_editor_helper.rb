# frozen_string_literal: true

module EE::Projects::Ci::PipelineEditorHelper
  extend ::Gitlab::Utils::Override

  override :js_pipeline_editor_data
  def js_pipeline_editor_data(project)
    super.merge(
      "api-fuzzing-configuration-path" => project_security_configuration_api_fuzzing_path(project)
    )
  end
end
