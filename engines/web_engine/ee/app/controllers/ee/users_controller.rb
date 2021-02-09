# frozen_string_literal: true

module EE
  module UsersController
    extend ::Gitlab::Utils::Override

    def available_project_templates
      load_custom_project_templates
    end

    def available_group_templates
      load_group_project_templates
    end

    private

    override :personal_projects
    def personal_projects
      super.with_compliance_framework_settings
    end

    override :contributed_projects
    def contributed_projects
      super.with_compliance_framework_settings
    end

    override :starred_projects
    def starred_projects
      super.with_compliance_framework_settings
    end

    def load_custom_project_templates
      @custom_project_templates ||= user.available_custom_project_templates(search: params[:search]).page(params[:page])
    end

    def load_group_project_templates
      @groups_with_project_templates ||=
        user.available_subgroups_with_custom_project_templates(params[:group_id])
            .page(params[:page])
    end
  end
end
