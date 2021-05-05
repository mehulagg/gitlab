# frozen_string_literal: true

module IdeHelper
  def ide_data
    {
      'empty-state-svg-path' => image_path('illustrations/multi_file_editor_empty.svg'),
      'no-changes-state-svg-path' => image_path('illustrations/multi-editor_no_changes_empty.svg'),
      'committed-state-svg-path' => image_path('illustrations/multi-editor_all_changes_committed_empty.svg'),
      'pipelines-empty-state-svg-path': image_path('illustrations/pipelines_empty.svg'),
      'promotion-svg-path': image_path('illustrations/web-ide_promotion.svg'),
      'ci-help-page-path' => help_page_path('ci/quick_start/README'),
      'web-ide-help-page-path' => help_page_path('user/project/web_ide/index.md'),
      'clientside-preview-enabled': Gitlab::CurrentSettings.web_ide_clientside_preview_enabled?.to_s,
      'render-whitespace-in-code': current_user.render_whitespace_in_code.to_s,
      'codesandbox-bundler-url': Gitlab::CurrentSettings.web_ide_clientside_preview_bundler_url,
      'branch-name' => @branch,
      'file-path' => @path,
      'merge-request' => @merge_request,
      'fork-info' => @fork_info&.to_json,
      'project' => convert_to_project_entity_json(@project)
    }
  end

  private

  def convert_to_project_entity_json(project)
    return unless project

    API::Entities::Project.represent(project).to_json
  end
end

::IdeHelper.prepend_mod_with('IdeHelper')
