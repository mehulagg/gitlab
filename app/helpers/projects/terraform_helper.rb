# frozen_string_literal: true

module Projects::TerraformHelper
  def js_terraform_list_data(project)
    {
      empty_state_image: image_path('illustrations/clusters_empty.svg'),
      project_path: project.full_path
    }
  end
end
