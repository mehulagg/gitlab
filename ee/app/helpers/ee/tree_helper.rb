# frozen_string_literal: true

module EE
  module TreeHelper
    extend ::Gitlab::Utils::Override

    override :vue_file_list_data
    def vue_file_list_data(project, ref)
      super.merge({
        path_locks_available: project.feature_available?(:file_locks).to_s,
        path_locks_toggle: toggle_project_path_locks_path(project)
      })
    end
  end
end
